/* aimsMine.js
*This are the scripts that are used for the select menu 
* and any other customization made by Oscar
*/

// xml respose mode for query access with lat lon
query_accessXMLMode_latlon = 23;
var cVersion = "&ClientVersion=3.1";

function query_access(){
//alert("in","");
var choice = 0;
var path = Number(document.forms[0].elements[0].value);
var pathString = document.forms[0].elements[0].value;
var row = Number(document.forms[0].elements[1].value);
var rowString = document.forms[0].elements[1].value;
var from_month = document.forms[0].elements[2].value;
var from_year = document.forms[0].elements[3].value;
var to_month = document.forms[0].elements[4].value;
var to_year = document.forms[0].elements[5].value;
var cloud = document.forms[0].elements[6].value;
var sort = document.forms[0].elements[7].value;

var can_go = "";

// If using path/row make sure that are numeric and valid path/row values
if(choice == 0){
//alert("inside path/row option","");
	if (pathString != "" && rowString != ""){
			if (isNaN(path)){NaN_notice("path")}
			else{
				if(isNaN(row)){NaN_notice("row")}
				else{
					if (path < 234 && path > 0){
							if(row <121 && row >0){can_go = "yes_with_parow"}
							else {bad_notice(row,"row")}
					}
					else {bad_notice(path,"path")}
         			}
			}
	}
	else {empty_notice("Path & Row")}
}

// If using lat/lon make sure that are numeric and valid lat.lon values

if(choice == 1){
	if (latString != "" && lonString != ""){
			if(isNaN(lat)){NaN_notice("Latitude")}
			else{
				if(isNaN(lon)){NaN_notice("Longitude")}
				else{
						if(lat < 90 && lat > -90){
								if(lon < 180 && lon > -180){can_go = "yes_with_latlon";}
								else {bad_notice(lon,"longitude")}
						}
						else {bad_notice(lat,"latitude")}
				}
			}
	}
	else{empty_notice("Latitude & Longitude")}
}

//Now that we know that lat/lon or path/row are valid, build the query string
if(can_go == "yes_with_parow"){
	var queryString = "http://35.8.163.123/access8/access8.asp?";
	var queryString = queryString + "initialParow=";
	if(pathString.length == 1) pathString = "00"+pathString;
	if(pathString.length == 2) pathString = "0"+pathString;
	if(rowString.length == 1) rowString = "00"+rowString;
	if(rowString.length == 2) rowString = "0"+rowString;
	var parowvalue = pathString+rowString;
	
	//alert(parowvalue,"");
	executeFind(parowvalue);
	//ORIGINAL:
	//var theQueryString = "http://35.8.163.123/access8/access6.asp?sensor=OLI&Parow1=" + parowvalue + "&tilesNum=1&cloud=" + cloud;
	var theQueryString = "http://35.8.163.123/beta/access_v_2_1/access8/access8.asp?sensor=OLI&tilesNum=1&Parow1=" + parowvalue + "&StartMonth=" + from_month + "&StartYear=" + from_year + "&EndMonth=" + to_month + "&EndYear=" + to_year + "&Cloud=" + cloud + "&Sort=" + sort;
	//alert(theQueryString);
	var resultsWindow = window.open(theQueryString,"Results","");
	resultsWindow.focus();
}

if(can_go == "yes_with_latlon"){
          mapExtension.removeFromMap(gOverlays);
          gOverlays=null;
          parcelQuery.queryGeometry = new GLatLng(lat,lon);
          parcelQueryTask.execute(parcelQuery, false, addResultsLatLng);
          //LatLong_to_PathRow(GLatLng)
}
//Next line is the end of function query_access()
}
		
function bad_notice(bad_value,which){
alert(bad_value+" is an invalid "+which)
} 

function NaN_notice(which){
alert(which+" is invalid, you need a numerical value.");
}

function empty_notice(which){
alert(which+" inputs are necessary to query Access7")
}

function clean_values(the_cleaned){
theValue = new Number(the_cleaned)
document.forms[0].elements[theValue].value = "";
theValue++
document.forms[0].elements[theValue].value = "";
}

function refocus(value){
theValue = new Number(value);
document.forms[0].elements[theValue].checked = true;
}
//NEED TO CREATE: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/**
// use GLatLng to get ["PAROW"] from fields of wrsii
function LatLong_to_PathRow(GLatLng){ 
	// Find Task
    findTask = new esri.arcgis.gmaps.FindTask("http://35.8.163.50/ArcGIS/rest/services/wrsii/MapServer");

    // Find Parameters
    params = new esri.arcgis.gmaps.FindParameters();
    params.layerIds = [0];
    params.searchFields = ["PAROW"];
	//more...........
	
	//....
	var theQueryString = "http://35.8.163.123/beta/access_v_2_1/access8/access8.asp?sensor=OLI&tilesNum=1&Parow1=" + parowvalue + "&StartMonth=" + from_month + "&StartYear=" + from_year + "&EndMonth=" + to_month + "&EndYear=" + to_year + "&Cloud=" + cloud + "&Sort=" + sort;
	var resultsWindow = window.open(theQueryString,"Results","");
	resultsWindow.focus();
}
**/
