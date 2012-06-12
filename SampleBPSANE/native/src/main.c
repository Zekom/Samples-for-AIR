/*
* Copyright (c) 2012 Research In Motion Limited.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


#include "FlashRuntimeExtensions.h"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <math.h>
#include <string.h>

#include <bps/bps.h>
#include <bps/sensor.h>
#include <pthread.h>

#include <bps/event.h>
#include <assert.h>
#include "limits.h"


void ContextInitializer(void* extData, const uint8_t* ctxType,
		FREContext ctx, uint32_t* numFunctionsToSet,
		const FRENamedFunction** functionsToSet);
void extensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void extensionFinalizer(void* extData);
void ContextFinalizer(FREContext ctx);

FREObject startSensor(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject stopSensor(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject isSensorSupported(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject skipDuplicateEvents(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject setSensorRate(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getSensorResolution(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getSensorRangeMin(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getSensorRangeMax(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getSensorDelayMin(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getSensorDelayMax(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);
FREObject getSensorDelayDefault(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);

FREObject getAPRValues(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[]);


static uint64_t QNXGetTimeNS() {
	struct timespec currentTimeSpec;
	int err = clock_gettime(CLOCK_MONOTONIC, &currentTimeSpec);
	return timespec2nsec(&currentTimeSpec);
}

long GetProcessTime() {
	static bool timeInited = false;
	static uint64_t startTime;

	long result;
	if (timeInited) {
		result = (QNXGetTimeNS() - startTime) / 1000000LL;
	} else {
		startTime = QNXGetTimeNS();
		timeInited = true;
		result = 0;
	}
	return result;
}


FREContext context;

void ContextInitializer(void* extData, const uint8_t* ctxType,
				   FREContext ctx, uint32_t* numFunctionsToSet,
				   const FRENamedFunction** functionsToSet)
{

	context = ctx;

	static FRENamedFunction s_classMethods[] =
	{
		{(const uint8_t *)"startSensor", NULL, startSensor},
		{(const uint8_t *)"stopSensor", NULL, stopSensor},
		{(const uint8_t *)"isSensorSupported", NULL, isSensorSupported},
		{(const uint8_t *)"skipDuplicateEvents", NULL, skipDuplicateEvents},
		{(const uint8_t *)"setSensorRate", NULL, setSensorRate},

		{(const uint8_t *)"getSensorResolution", NULL, getSensorResolution},
		{(const uint8_t *)"getSensorRangeMin", NULL, getSensorRangeMin},
		{(const uint8_t *)"getSensorRangeMax", NULL, getSensorRangeMax},
		{(const uint8_t *)"getSensorDelayMin", NULL, getSensorDelayMin},
		{(const uint8_t *)"getSensorDelayMax", NULL, getSensorDelayMax},
		{(const uint8_t *)"getSensorDelayDefault", NULL, getSensorDelayDefault},

		{(const uint8_t *)"getAPRValues", NULL, getAPRValues}

	};

	const int c_methodCount = sizeof(s_classMethods) / sizeof(FRENamedFunction);

	// Update caller with the required data
	*functionsToSet = s_classMethods;
	*numFunctionsToSet = c_methodCount;
}

typedef struct _APRData APRData;

struct _APRData
{
	float a;
	float p;
	float r;
	bool newData;
	long timestamp;
	sensor_accuracy_t accuracy;
};

typedef struct
{
    int channel_id;
    int domain_id;
    char output[1024];
} thread_payload_t;

enum
{
    MASTER_EXIT = 0,
    MASTER_CONNECT,
    MASTER_OUTPUT,
    MASTER_START,
    MASTER_STOP,
    MASTER_DUPLICATES,
    MASTER_RATE,
};


pthread_mutex_t amutex;
APRData aprData;

int threadDomain;
int threadChannel;
int masterDomain;

static void
complete_thread_event(bps_event_t *event)
{
    bps_event_payload_t *payload = bps_event_get_payload(event);
    thread_payload_t* thread_payload = (thread_payload_t*)payload->data1;
    free(thread_payload);

    bps_event_destroy(event);
}

static bps_event_t *
create_thread_event(const thread_payload_t *thread_payload, int code)
{
    thread_payload_t *copy_payload;
    copy_payload = (thread_payload_t*)malloc(sizeof(*copy_payload));
    memcpy(copy_payload, thread_payload, sizeof(*copy_payload));

    bps_event_payload_t payload;
    payload.data1 = (uintptr_t)copy_payload;

    bps_event_t *event;
    bps_event_create(&event, thread_payload->domain_id, code, &payload, &complete_thread_event);

    return event;
}

static void
connect_thread(thread_payload_t *thread_data)
{
    bps_event_t *event;
    bps_get_event(&event, -1);
    assert(event);
    assert(bps_event_get_code(event) == MASTER_CONNECT);

    thread_payload_t *thread_payload;
    bps_event_payload_t *payload = bps_event_get_payload(event);
    thread_payload = (thread_payload_t*)payload->data1;

    memcpy(thread_data, thread_payload, sizeof(*thread_data));

    // push back as an 'ack'
    bps_channel_push_event(thread_data->channel_id, event);

}


static void* threadMethod(void* p)
{
	int main_channel = (int)p;

	bps_initialize();

    thread_payload_t thread_payload;
    thread_payload.channel_id = bps_channel_get_active();
    thread_payload.domain_id = bps_register_domain();
    thread_payload.output[0] = '\0';

    bps_event_t *event = create_thread_event(&thread_payload, MASTER_CONNECT);

    bps_channel_push_event(main_channel, event);

    bps_get_event(&event, -1);
    assert(event);
    assert(bps_event_get_code(event) == MASTER_CONNECT);

	float azimoth;
	float pitch;
	float roll;

	int success;

	while( true )
	{

		bps_get_event(&event, -1);

		int domain = bps_event_get_domain(event);
		int code = bps_event_get_code(event);

		if( domain == masterDomain )
		{
			bool reply = false;
			if( code == MASTER_START )
			{
				bps_event_payload_t *payload = bps_event_get_payload(event);
				success = sensor_request_events( payload->data1 );
				reply = true;

			}
			else if( code == MASTER_STOP )
			{
				bps_event_payload_t *payload = bps_event_get_payload(event);
				success = sensor_stop_events( payload->data1 );
				reply = true;
			}
			else if( code == MASTER_DUPLICATES )
			{
				bps_event_payload_t *payload = bps_event_get_payload(event);
				success = sensor_set_skip_duplicates( payload->data1, payload->data2 );
				reply = true;
			}
			else if( code == MASTER_RATE )
			{
				bps_event_payload_t *payload = bps_event_get_payload(event);
				success = sensor_set_rate( payload->data1, payload->data2 );
				reply = true;
			}

			if( reply )
			{
				bps_event_t *return_event;
				bps_event_payload_t return_payload;

				if( success == BPS_SUCCESS )
				{
					success = 1;
				}
				else
				{
					success = 0;
				}
				return_payload.data1 = success;

				bps_event_create( &return_event, thread_payload.domain_id, MASTER_OUTPUT, &return_payload, NULL );
				bps_channel_push_event( main_channel, return_event );

			}
		}
		else if( domain == sensor_get_domain())
		{
			success = BPS_FAILURE;

			switch ( bps_event_get_code(event) )
			{
				case SENSOR_AZIMUTH_PITCH_ROLL_READING:
					success = sensor_event_get_apr( event, &azimoth, &pitch, &roll );

					if( success == BPS_SUCCESS )
					{
						pthread_mutex_lock(&amutex);
						aprData.a = azimoth;
						aprData.p = pitch;
						aprData.r = roll;
						aprData.timestamp = GetProcessTime();
						aprData.accuracy = sensor_event_get_accuracy(event);
						if( !aprData.newData )
						{
							FREDispatchStatusEventAsync(context, (const uint8_t *)"apr", (const uint8_t *)"newdata");
							aprData.newData = true;
						}
						pthread_mutex_unlock(&amutex);
					}
					break;
			}
		}
	}
	return NULL;
}


// Initialization function of each extension
void extensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	int success = bps_initialize();

	masterDomain = bps_register_domain();

	*extDataToSet = NULL;
	*ctxInitializerToSet = &ContextInitializer;
	*ctxFinalizerToSet = &ContextFinalizer;
	pthread_mutex_init(&amutex, NULL);
	pthread_create(NULL, NULL, threadMethod, (void *)bps_channel_get_active());

	thread_payload_t payload;
	connect_thread( &payload );

	threadDomain = payload.domain_id;
	threadChannel = payload.channel_id;
}




// Called when extension is unloaded
void extensionFinalizer(void* extData)
{
	bps_shutdown();
	return;
}

void ContextFinalizer(FREContext ctx) {
	return;
}

FREObject get_thread_result()
{
	FREObject result;

	while( true )
	{
		bps_event_t *event;
		bps_get_event(&event, -1);

		int domain = bps_event_get_domain(event);
		int code = bps_event_get_code(event);
		if( domain == threadDomain )
		{
			if( code == MASTER_OUTPUT )
			{
				bps_event_payload_t *thread_event_payload = bps_event_get_payload( event );
				FRENewObjectFromInt32( thread_event_payload->data1, &result );
				return( result );
			}

		}
	}
	FRENewObjectFromInt32( 0, &result );
	return( result );
}


FREObject isSensorSupported(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	bool isSupported = sensor_is_supported( (sensor_type_t)type );

	FREObject result;
	FRENewObjectFromBool( (uint32_t)isSupported, &result );
	return( result );

}

FREObject skipDuplicateEvents(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );

	uint32_t skip;
	FREGetObjectAsBool( argv[1], &skip );

	bps_event_t *event;
	bps_event_payload_t payload;
	payload.data1 = (sensor_type_t)type;
	payload.data2 = (bool)skip;

	bps_event_create( &event, masterDomain, MASTER_DUPLICATES, &payload, NULL );
	bps_channel_push_event( threadChannel, event );

	return( get_thread_result() );

}

FREObject startSensor(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	bps_event_t *event;
	bps_event_payload_t payload;
	payload.data1 = (sensor_type_t)type;

	bps_event_create( &event, masterDomain, MASTER_START, &payload, NULL );
	bps_channel_push_event( threadChannel, event );

	return( get_thread_result() );
}


FREObject stopSensor(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	bps_event_t *event;
	bps_event_payload_t payload;
	payload.data1 = (sensor_type_t)type;

	bps_event_create( &event, masterDomain, MASTER_STOP, &payload, NULL );
	bps_channel_push_event( threadChannel, event );

	return( get_thread_result() );
}

FREObject setSensorRate(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );

	double rate;
	FREGetObjectAsDouble( argv[1], &rate );

	//convert milliseconds to microseconds
	rate = rate * 1000;

	if( rate > UINT_MAX )
	{
		rate = UINT_MAX;
	}

	bps_event_t *event;
	bps_event_payload_t payload;
	payload.data1 = (sensor_type_t)type;
	payload.data2 = (unsigned int)rate;

	bps_event_create( &event, masterDomain, MASTER_RATE, &payload, NULL );
	bps_channel_push_event( threadChannel, event );

	return( get_thread_result() );
}

FREObject getSensorResolution(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	sensor_info_t *info;
	int success = sensor_info( (sensor_type_t)type, &info);

	float resolution = sensor_info_get_resolution( info );

	FREObject result;
	FRENewObjectFromDouble( (double)resolution, &result );

	sensor_info_destroy( info );

	return( result );

}

FREObject getSensorRangeMin(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	sensor_info_t *info;
	int success = sensor_info( (sensor_type_t)type, &info);

	float resolution = sensor_info_get_range_minimum( info );

	FREObject result;
	FRENewObjectFromDouble( (double)resolution, &result );

	sensor_info_destroy( info );

	return( result );
}

FREObject getSensorRangeMax(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	sensor_info_t *info;
	int success = sensor_info( (sensor_type_t)type, &info);

	float resolution = sensor_info_get_range_maximum( info );

	FREObject result;
	FRENewObjectFromDouble( (double)resolution, &result );

	sensor_info_destroy( info );

	return( result );
}

FREObject getSensorDelayMin(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	sensor_info_t *info;
	int success = sensor_info( (sensor_type_t)type, &info);

	unsigned int resolution = sensor_info_get_delay_mininum( info );

	FREObject result;
	FRENewObjectFromInt32( (int32_t)resolution, &result );

	sensor_info_destroy( info );


	return( result );
}

FREObject getSensorDelayMax(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	sensor_info_t *info;
	int success = sensor_info( (sensor_type_t)type, &info);

	unsigned int resolution = sensor_info_get_delay_maximum( info );

	FREObject result;
	FRENewObjectFromInt32( (int32_t)resolution, &result );

	sensor_info_destroy( info );

	return( result );
}

FREObject getSensorDelayDefault(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{
	int32_t type;
	FREGetObjectAsInt32( argv[ 0 ], &type );
	sensor_info_t *info;
	int success = sensor_info( (sensor_type_t)type, &info);

	unsigned int resolution = sensor_info_get_delay_default( info );

	FREObject result;
	FRENewObjectFromInt32( (int32_t)resolution, &result );

	sensor_info_destroy( info );

	return( result );
}

FREObject getAPRValues(FREContext ctx, void* functionData, uint32_t argc, FREObject argv[])
{

	FREObject result;

	pthread_mutex_lock(&amutex);

	const int cNumAttributes = 6;
	FREObject resultAttributes[cNumAttributes];

	const char *eventType = "APRUpdate";
	FRENewObjectFromUTF8((uint32_t)(strlen(eventType) + 1), (uint8_t*)eventType, &resultAttributes[0]);

	FRENewObjectFromDouble( (double)aprData.a, &resultAttributes[1] );
	FRENewObjectFromDouble( (double)aprData.p, &resultAttributes[2] );
	FRENewObjectFromDouble( (double)aprData.r, &resultAttributes[3] );
	FRENewObjectFromInt32( (int32_t)aprData.accuracy, &resultAttributes[4] );
	FRENewObjectFromDouble( (double)aprData.timestamp, &resultAttributes[5] );

	FREResult success = FRENewObject((const uint8_t*) "Array", cNumAttributes, resultAttributes, &result, NULL);
	aprData.newData = false;
	pthread_mutex_unlock(&amutex);



	return result;

}
