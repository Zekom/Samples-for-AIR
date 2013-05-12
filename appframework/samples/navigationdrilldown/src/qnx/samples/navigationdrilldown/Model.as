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
package qnx.samples.navigationdrilldown
{
	import qnx.ui.data.DataProvider;
	import qnx.ui.data.IDataProvider;
	/**
	 * @author jdolce
	 */
	public class Model
	{
		
		public static const data:IDataProvider = new DataProvider();
		{
			data.addItem( {label:"Africa", children:getAfrica() } );
			data.addItem( {label:"Asia", children:getAsia() } );
			data.addItem( {label:"Europe", children:getEurope() } );
			data.addItem( {label:"Oceania", children:getOceania()} );
			data.addItem( {label:"North America", children:getNorthAmerica() } );
			data.addItem( {label:"South America", children:getSouthAmerica() } );
		}
			
		private static function getSouthAmerica():IDataProvider
		{
			var dp:IDataProvider = new DataProvider();
			dp.addItem( {label:"Argentina", capital:"Buenos Aires"});
				dp.addItem( {label:"Bolivia", capital:"La Paz"});
				dp.addItem( {label:"Brazil", capital:"Brasilia"});
				dp.addItem( {label:"Chile", capital:"Santiago"});
				dp.addItem( {label:"Colombia", capital:"Bogota"});
				dp.addItem( {label:"Ecuador", capital:"Quito"});
				dp.addItem( {label:"Guyana", capital:"Georgetown"});
				dp.addItem( {label:"Paraguay", capital:"Asuncion"});
				dp.addItem( {label:"Peru", capital:"Lima"});
				dp.addItem( {label:"Suriname", capital:"Paramaribo"});
				dp.addItem( {label:"Uruguay", capital:"Montevideo"});
				dp.addItem( {label:"Venezuela", capital:"Caracas"});
			return( dp );
		}


		private static function getNorthAmerica():IDataProvider
		{
			var dp:IDataProvider = new DataProvider();
			dp.addItem( {label:"Antigua and Barbuda", capital:"Saint John's"});
				dp.addItem( {label:"Bahamas", capital:"Nassau"});
				dp.addItem( {label:"Barbados", capital:"Bridgetown"});
				dp.addItem( {label:"Belize", capital:"Belmopan"});
				dp.addItem( {label:"Canada", capital:"Ottawa"});
				dp.addItem( {label:"Costa Rica", capital:"San Jose"});
				dp.addItem( {label:"Cuba", capital:"Havana"});
				dp.addItem( {label:"Dominica", capital:"Roseau"});
				dp.addItem( {label:"Dominican Republic", capital:"Santo Domingo"});
				dp.addItem( {label:"El Salvador", capital:"San Salvador"});
				dp.addItem( {label:"Grenada", capital:"Saint George's"});
				dp.addItem( {label:"Guatemala", capital:"Guatemala City"});
				dp.addItem( {label:"Haiti", capital:"Port-au-Prince"});
				dp.addItem( {label:"Honduras", capital:"Tegucigalpa"});
				dp.addItem( {label:"Jamaica", capital:"Kingston"});
				dp.addItem( {label:"Mexico", capital:"Mexico City"});
				dp.addItem( {label:"Nicaragua", capital:"Managua"});
				dp.addItem( {label:"Panama", capital:"Panama City"});
				dp.addItem( {label:"Saint Kitts and Nevis", capital:"Basseterre"});
				dp.addItem( {label:"Saint Lucia", capital:"Castries"});
				dp.addItem( {label:"Saint Vincent and the Grenadines", capital:"Kingstown"});
				dp.addItem( {label:"Trinidad and Tobago", capital:"Port-of-Spain"});
				dp.addItem( {label:"United States", capital:"Washington D.C."});
			return( dp );
		}
		
		
		private static function getOceania():IDataProvider
		{
			var dp:IDataProvider = new DataProvider();
			dp.addItem( {label:"Australia", capital:"Canberra"});
				dp.addItem( {label:"Fiji", capital:"Suva"});
				dp.addItem( {label:"Kiribati", capital:"Tarawa Atoll"});
				dp.addItem( {label:"Marshall Islands", capital:"Majuro"});
				dp.addItem( {label:"Micronesia", capital:"Palikir"});
				dp.addItem( {label:"Nauru", capital:"Yaren District"});
				dp.addItem( {label:"New Zealand", capital:"Wellington"});
				dp.addItem( {label:"Palau", capital:"Melekeok"});
				dp.addItem( {label:"Papua New Guinea", capital:"Port Moresby"});
				dp.addItem( {label:"Samoa", capital:"Apia"});
				dp.addItem( {label:"Solomon Islands", capital:"Honiara"});
				dp.addItem( {label:"Tonga", capital:"Nuku'alofa"});
				dp.addItem( {label:"Tuvalu", capital:"Vaiaku village, Funafuti province"});
				dp.addItem( {label:"Vanuatu", capital:"Port-Vila"});
			return( dp );
		}
		
		private static function getEurope():IDataProvider
		{
			var dp:IDataProvider = new DataProvider();
			dp.addItem( {label:"Albania", capital:"Tirana"});
				dp.addItem( {label:"Andorra", capital:"Andorra la Vella"});
				dp.addItem( {label:"Armenia", capital:"Yerevan"});
				dp.addItem( {label:"Austria", capital:"Vienna"});
				dp.addItem( {label:"Azerbaijan", capital:"Baku"});
				dp.addItem( {label:"Belarus", capital:"Minsk"});
				dp.addItem( {label:"Belgium", capital:"Brussels"});
				dp.addItem( {label:"Bosnia and Herzegovina", capital:"Sarajevo"});
				dp.addItem( {label:"Bulgaria", capital:"Sofia"});
				dp.addItem( {label:"Croatia", capital:"Zagreb"});
				dp.addItem( {label:"Cyprus", capital:"Nicosia"});
				dp.addItem( {label:"Czech Republic", capital:"Prague"});
				dp.addItem( {label:"Denmark", capital:"Copenhagen"});
				dp.addItem( {label:"Estonia", capital:"Tallinn"});
				dp.addItem( {label:"Finland", capital:"Helsinki"});
				dp.addItem( {label:"France", capital:"Paris"});
				dp.addItem( {label:"Georgia", capital:"Tbilisi"});
				dp.addItem( {label:"Germany", capital:"Berlin"});
				dp.addItem( {label:"Greece", capital:"Athens"});
				dp.addItem( {label:"Hungary", capital:"Budapest"});
				dp.addItem( {label:"Iceland", capital:"Reykjavik"});
				dp.addItem( {label:"Ireland", capital:"Dublin"});
				dp.addItem( {label:"Italy", capital:"Rome"});
				dp.addItem( {label:"Latvia", capital:"Riga"});
				dp.addItem( {label:"Liechtenstein", capital:"Vaduz"});
				dp.addItem( {label:"Lithuania", capital:"Vilnius"});
				dp.addItem( {label:"Luxembourg", capital:"Luxembourg"});
				dp.addItem( {label:"Macedonia", capital:"Skopje"});
				dp.addItem( {label:"Malta", capital:"Valletta"});
				dp.addItem( {label:"Moldova", capital:"Chisinau"});
				dp.addItem( {label:"Monaco", capital:"Monaco"});
				dp.addItem( {label:"Montenegro", capital:"Podgorica"});
				dp.addItem( {label:"Netherlands", capital:"Amsterdam"});
				dp.addItem( {label:"Norway", capital:"Oslo"});
				dp.addItem( {label:"Poland", capital:"Warsaw"});
				dp.addItem( {label:"Portugal", capital:"Lisbon"});
				dp.addItem( {label:"Romania", capital:"Bucharest"});
				dp.addItem( {label:"San Marino", capital:"San Marino"});
				dp.addItem( {label:"Serbia", capital:"Belgrade"});
				dp.addItem( {label:"Slovakia", capital:"Bratislava"});
				dp.addItem( {label:"Slovenia", capital:"Ljubljana"});
				dp.addItem( {label:"Spain", capital:"Madrid"});
				dp.addItem( {label:"Sweden", capital:"Stockholm"});
				dp.addItem( {label:"Switzerland", capital:"Bern"});
				dp.addItem( {label:"Ukraine", capital:"Kyiv"});
				dp.addItem( {label:"United Kingdom", capital:"London"});
				dp.addItem( {label:"Vatican City", capital:"Vatican City"});
			return( dp );
		}
		
		private static function getAsia():IDataProvider
		{
				var dp:DataProvider = new DataProvider();
				dp.addItem( {label:"Afghanistan", capital:"Kabul"});
				dp.addItem( {label:"Bahrain", capital:"Manama"});
				dp.addItem( {label:"Bangladesh", capital:"Dhaka"});
				dp.addItem( {label:"Bhutan", capital:"Thimphu"});
				dp.addItem( {label:"Brunei", capital:"Bandar Seri Begawan"});
				dp.addItem( {label:"Burma (Myanmar)", capital:"Rangoon"});
				dp.addItem( {label:"Cambodia", capital:"Phnom Penh"});
				dp.addItem( {label:"China", capital:"Beijing"});
				dp.addItem( {label:"East Timor", capital:"Dili"});
				dp.addItem( {label:"India", capital:"New Delhi"});
				dp.addItem( {label:"Indonesia", capital:"Jakarta"});
				dp.addItem( {label:"Iran", capital:"Tehran"});
				dp.addItem( {label:"Iraq", capital:"Baghdad"});
				dp.addItem( {label:"Israel", capital:"Jerusalem"});
				dp.addItem( {label:"Japan", capital:"Tokyo"});
				dp.addItem( {label:"Jordan", capital:"Amman"});
				dp.addItem( {label:"Kazakhstan", capital:"Astana"});
				dp.addItem( {label:"Korea, North", capital:"Pyongyang"});
				dp.addItem( {label:"Korea, South", capital:"Seoul"});
				dp.addItem( {label:"Kuwait", capital:"Kuwait City"});
				dp.addItem( {label:"Kyrgyzstan", capital:"Bishkek"});
				dp.addItem( {label:"Laos", capital:"Vientiane"});
				dp.addItem( {label:"Lebanon", capital:"Beirut"});
				dp.addItem( {label:"Malaysia", capital:"Kuala Lumpur"});
				dp.addItem( {label:"Maldives", capital:"Male"});
				dp.addItem( {label:"Mongolia", capital:"Ulaanbaatar"});
				dp.addItem( {label:"Nepal", capital:"Kathmandu"});
				dp.addItem( {label:"Oman", capital:"Muscat"});
				dp.addItem( {label:"Pakistan", capital:"Islamabad"});
				dp.addItem( {label:"Philippines", capital:"Manila"});
				dp.addItem( {label:"Qatar", capital:"Doha"});
				dp.addItem( {label:"Russia", capital:"Moscow"});
				dp.addItem( {label:"Saudi Arabia", capital:"Riyadh"});
				dp.addItem( {label:"Singapore", capital:"Singapore"});
				dp.addItem( {label:"Sri Lanka", capital:"Colombo"});
				dp.addItem( {label:"Syria", capital:"Damascus"});
				dp.addItem( {label:"Tajikistan", capital:"Dushanbe"});
				dp.addItem( {label:"Thailand", capital:"Bangkok"});
				dp.addItem( {label:"Turkey", capital:"Ankara"});
				dp.addItem( {label:"Turkmenistan", capital:"Ashgabat"});
				dp.addItem( {label:"United Arab Emirates", capital:"Abu Dhabi"});
				dp.addItem( {label:"Uzbekistan", capital:"Tashkent"});
				dp.addItem( {label:"Vietnam", capital:"Hanoi"});
				dp.addItem( {label:"Yemen", capital:"Sanaa"});
				
				return( dp );
		}
		
		
		private static function getAfrica():IDataProvider
		{
			var africa:IDataProvider = new DataProvider();
			africa.addItem( {label:"Algeria", capital:"Algiers"});
			africa.addItem( {label:"Angola", capital:"Luanda"});
			africa.addItem( {label:"Benin", capital:"Porto-Novo"});
			africa.addItem( {label:"Botswana", capital:"Gaborone"});
			africa.addItem( {label:"Burkina", capital:"Faso - Ouagadougou"});
			africa.addItem( {label:"Burundi", capital:"Bujumbura"});
			africa.addItem( {label:"Cameroon", capital:"Yaounde"});
			africa.addItem( {label:"Cape Verde", capital:"Praia"});
			africa.addItem( {label:"Central African Republic", capital:"Bangui"});
			africa.addItem( {label:"Chad", capital:"N'Djamena"});
			africa.addItem( {label:"Comoros", capital:"Moroni"});
			africa.addItem( {label:"Congo", capital:"Brazzaville"});
			africa.addItem( {label:"Congo, Democratic Republic of", capital:"Kinshasa"});
			africa.addItem( {label:"Djibouti", capital:"Djibouti"});
			africa.addItem( {label:"Egypt", capital:"Cairo"});
			africa.addItem( {label:"Equatorial Guinea", capital:"Malabo"});
			africa.addItem( {label:"Eritrea", capital:"Asmara"});
			africa.addItem( {label:"Ethiopia", capital:"Addis Ababa"});
			africa.addItem( {label:"Gabon", capital:"Libreville"});
			africa.addItem( {label:"Gambia", capital:"Banjul"});
			africa.addItem( {label:"Ghana", capital:"Accra"});
			africa.addItem( {label:"Guinea", capital:"Conakry"});
			africa.addItem( {label:"Guinea-Bissau", capital:"Bissau"});
			africa.addItem( {label:"Ivory Coast", capital:"Yamoussoukro"});
			africa.addItem( {label:"Kenya", capital:"Nairobi"});
			africa.addItem( {label:"Lesotho", capital:"Maseru"});
			africa.addItem( {label:"Liberia", capital:"Monrovia"});
			africa.addItem( {label:"Libya", capital:"Tripoli"});
			africa.addItem( {label:"Madagascar", capital:"Antananarivo"});
			africa.addItem( {label:"Malawi", capital:"Lilongwe"});
			africa.addItem( {label:"Mali", capital:"Bamako"});
			africa.addItem( {label:"Mauritania", capital:"Nouakchott"});
			africa.addItem( {label:"Mauritius", capital:"Port Louis"});
			africa.addItem( {label:"Morocco", capital:"Rabat"});
			africa.addItem( {label:"Mozambique", capital:"Maputo"});
			africa.addItem( {label:"Namibia", capital:"Windhoek"});
			africa.addItem( {label:"Niger", capital:"Niamey"});
			africa.addItem( {label:"Nigeria", capital:"Abuja"});
			africa.addItem( {label:"Rwanda", capital:"Kigali"});
			africa.addItem( {label:"Sao Tome and Principe", capital:"Sao Tome"});
			africa.addItem( {label:"Senegal", capital:"Dakar"});
			africa.addItem( {label:"Seychelles", capital:"Victoria"});
			africa.addItem( {label:"Sierra Leone", capital:"Freetown"});
			africa.addItem( {label:"Somalia", capital:"Mogadishu"});
			africa.addItem( {label:"South Africa", capital:"Pretoria"});
			africa.addItem( {label:"South Sudan", capital:"Juba"});
			africa.addItem( {label:"Sudan", capital:"Khartoum"});
			africa.addItem( {label:"Swaziland", capital:"Mbabane"});
			africa.addItem( {label:"Tanzania", capital:"Dar es Salaam"});
			africa.addItem( {label:"Togo", capital:"Lome"});
			africa.addItem( {label:"Tunisia", capital:"Tunis"});
			africa.addItem( {label:"Uganda", capital:"Kampala"});
			africa.addItem( {label:"Zambia", capital:"Lusaka"});
			africa.addItem( {label:"Zimbabwe", capital:"Harare"});
			
			return( africa );
		}
		
	}
}
