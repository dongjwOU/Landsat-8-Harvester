    var map = null;
    var parcelQueryTask = null;
    var parcelQuery = null;
    var mapExtension;
    var gOverlays;
    var map_centerlatlng = new GLatLng(10,0);
    var haveSelection = false;
    
    function setMapLatLong(lat,lng){
    	map_centerlatlng = new GLatLng(lat,lng);
    	haveSelection = true;
    }
    
    function resetMapLatLong(lat,lng){
       	map_centerlatlng = new GLatLng(10,0);
       	haveSelection = false;
    }
    
    function LoadMap() {
      //Load Google Maps
      map = new GMap2(document.getElementById("mymap"));
	
      map.addMapType(G_PHYSICAL_MAP);
      map.addControl(new GLargeMapControl3D());
      map.addControl(new GMapTypeControl());
      map.setCenter(map_centerlatlng, 2, G_PHYSICAL_MAP);
      map.enableScrollWheelZoom();
	map.addControl(new GOverviewMapControl(new GSize(160,160))); 	
	map.addControl(new GScaleControl());

      //create mapextension class to be used to add/remove results from the map.
      mapExtension = new esri.arcgis.gmaps.MapExtension(map);

      //create mapOptions to specify opacity, minResolution, maxResolution when adding to the map.
      var mapOptions = {opacity: 0.75, minResolution:0, maxResolution: 19};

//GEvent.addListener(map, 'click', function(ovlay,latlng,ovlaylatlng) {
//         if (latlng != null) {
//            setMapLatLong(latlng.lat(),latlng.lng());
//         }
//}); 

GEvent.addListener(map, 'zoomend',function() {
	 if (haveSelection) map.panTo(map_centerlatlng);
});

      //Build ArcGIS Server Query Task and Filter against the Parcel Layer
      parcelQueryTask = new esri.arcgis.gmaps.QueryTask("http://35.8.163.50/ArcGIS/rest/services/wrsii/MapServer/0");

      parcelQuery = new esri.arcgis.gmaps.Query();
      parcelQuery.returnGeometry = true;
      parcelQuery.outFields = ["WRS2PATH","WRS2ROW","PAROW"];

      GEvent.addListener(map, "click", function(marker, point, ovlaylatlng) {
        if(!marker){
          mapExtension.removeFromMap(gOverlays);
          gOverlays=null;
          parcelQuery.queryGeometry = point;
          parcelQueryTask.execute(parcelQuery, false, addResults);
        }
        
        if (point != null) {
          setMapLatLong(point.lat(),point.lng());
        }
      });
      
        // Find Task
        findTask = new esri.arcgis.gmaps.FindTask("http://35.8.163.50/ArcGIS/rest/services/wrsii/MapServer");

        // You can execute a task and listen for the complete event or use the callback to get the results
        GEvent.addListener(findTask, "executecomplete", function() {
          //console.debug("'find task complete' event fired!!!");
        });

        // Find Parameters
        params = new esri.arcgis.gmaps.FindParameters();
        params.layerIds = [0];
        params.searchFields = ["PAROW"];
        
      }
      
         function executeFind(searchText) {
           // clear map overlays and event listeners using MapExtension removeFromMap
           mapExtension.removeFromMap(gOverlays);
   
           // set find parameters
           params.searchText = searchText;
   
           // execute find task
           findTask.execute(params, addResultsFind);
   
         }
   
         function findCompleteCallback(findResults) {
           // add the findresutls to google map without any style
           gOverlays = mapExtension.addToMap(findResults);
           var centerPoint = new GPoint(point.y,point.x);
           alert(point.x);
           map.centerAtLatLng(centerPoint);
      }

    function addTiledMap(gTileLayer) {
      //Add tile layer as a GTileLayerOverlay using mapExtension
      mapExtension.addToMap(gTileLayer);
    }

    function dynmapcallback(groundov) {
      //Add groundoverlay to map using gmap.addOverlay()
      //map.addOverlay(groundov);
      dynMapOv = groundov;
    }

    function addResults(fset) {
        //JS literal class esri.arcgis.gmaps.MarkerOptions
        var myMarkerOptions = {
          title: "2000 Population: {WRS2PATH}"
        }

        //JS literal class esri.arcgis.gmaps.OverlayOptions
      var overlayOptions = {
        strokeColor:"#FF0000",
        strokeWeight:3,
        strokeOpacity:0.75,
        fillColor:"#000066",
        fillOpacity:0.4
      };

        //JS literal class esri.arcgis.gmaps.InfoWindowOptions
        var infoWindowOptions = {
          content:"<div style='text-align:left;'><font face='Verdana, Arial, Helvetica, sans-serif' size='-1'>You selected Path {WRS2PATH} and Row {WRS2ROW}.&nbsp;<br/><a href=http://35.8.163.123/access8/access6.asp?sensor=oli&Parow1={PAROW}&tilesNum=1&cloud=10 target='_blank'> Search landsat.org</a> for imagery at <br>this location."
          //content:"<div style='text-align:left;'><font face='Verdana, Arial, Helvetica, sans-serif' size='-1'>You selected Path {WRS2PATH} and Row {WRS2ROW}.&nbsp;<br/><a href=http://35.8.163.123/access8/access6.asp?sensor=etm&Parow1={PAROW}&tilesNum=1&cloud=10 target='_blank'> Search landsat.org</a> for imagery at <br>this location."
        };
      gOverlays = mapExtension.addToMap(fset,overlayOptions,infoWindowOptions);
      //var theSize = fset[0].displayFieldName;
      //var v = fset;
      //alert(v.geometryType);
      //alert(v.displayFieldName);
      //alert(v.features.length);
      //alert(v.features[0].geometry.length);
      //alert(v.features[0].geometry[0].getVertexCount());
      //alert(v.features[0].geometry[0].getVertex(0));
      //alert(fset.features[0].geometry[0].getBounds());
      
          var theBounds = fset.features[0].geometry[0].getBounds();
          var theSouthWest = theBounds.getSouthWest();
          var theSouthWestUrl = theSouthWest.toUrlValue(10);
          var theNorthEast = theBounds.getNorthEast();
          var theNorthEastUrl = theNorthEast.toUrlValue(10);
          var SouthWestArray = theSouthWestUrl.split(",");
          var NorthEastArray = theNorthEastUrl.split(",");
          var theCenterX = (parseFloat(SouthWestArray[0]) + parseFloat(NorthEastArray[0]))/2;
          var theCenterY = (parseFloat(SouthWestArray[1]) + parseFloat(NorthEastArray[1]))/2;
    //setMapLatLong(theCenterX,theCenterY); 
    //map.panTo(new GLatLng(theCenterX,theCenterY));

  }
 
     function addResultsLatLng(fset) {
         //JS literal class esri.arcgis.gmaps.MarkerOptions
         var myMarkerOptions = {
           title: "2000 Population: {WRS2PATH}"
         }
 
         //JS literal class esri.arcgis.gmaps.OverlayOptions
       var overlayOptions = {
         strokeColor:"#FF0000",
         strokeWeight:3,
         strokeOpacity:0.75,
         fillColor:"#000066",
         fillOpacity:0.4
       };
 
         //JS literal class esri.arcgis.gmaps.InfoWindowOptions
         var infoWindowOptions = {
 
           content:"<div style='text-align:left;'><font face='Verdana, Arial, Helvetica, sans-serif' size='-1'>You selected Path {WRS2PATH} and Row {WRS2ROW}.&nbsp;<br/><a href=http://35.8.163.123/access8/access6.asp?sensor=oli&Parow1={PAROW}&tilesNum=1&cloud=10 target='_blank'> Search landsat.org</a> for imagery at <br>this location."
           //content:"<div style='text-align:left;'><font face='Verdana, Arial, Helvetica, sans-serif' size='-1'>You selected Path {WRS2PATH} and Row {WRS2ROW}.&nbsp;<br/><a href=http://35.8.163.123/access8/access6.asp?sensor=etm&Parow1={PAROW}&tilesNum=1&cloud=10 target='_blank'> Search landsat.org</a> for imagery at <br>this location."
         };
 
       gOverlays = mapExtension.addToMap(fset,overlayOptions,infoWindowOptions);
       //var theSize = fset[0].displayFieldName;
       //var v = fset;
       //alert(v.geometryType);
       //alert(v.displayFieldName);
       //alert(v.features.length);
       //alert(v.features[0].geometry.length);
       //alert(v.features[0].geometry[0].getVertexCount());
       //alert(v.features[0].geometry[0].getVertex(0));
       //alert(fset.features[0].geometry[0].getBounds());
       
           var theBounds = fset.features[0].geometry[0].getBounds();
           var theSouthWest = theBounds.getSouthWest();
           var theSouthWestUrl = theSouthWest.toUrlValue(10);
           var theNorthEast = theBounds.getNorthEast();
           var theNorthEastUrl = theNorthEast.toUrlValue(10);
           var SouthWestArray = theSouthWestUrl.split(",");
           var NorthEastArray = theNorthEastUrl.split(",");
           var theCenterX = (parseFloat(SouthWestArray[0]) + parseFloat(NorthEastArray[0]))/2;
           var theCenterY = (parseFloat(SouthWestArray[1]) + parseFloat(NorthEastArray[1]))/2;
     setMapLatLong(theCenterX,theCenterY); 
     map.panTo(new GLatLng(theCenterX,theCenterY));
 
  }
 
  function addResultsFind(fset) {
    //JS literal class esri.arcgis.gmaps.MarkerOptions
    var myMarkerOptions = {
      title: "2000 Population: {WRS2PATH}"
    }
  
    //JS literal class esri.arcgis.gmaps.OverlayOptions
    var overlayOptions = {
      strokeColor:"#FF0000",
      strokeWeight:3,
      strokeOpacity:0.75,
      fillColor:"#000066",
      fillOpacity:0.4
    };
  
    //JS literal class esri.arcgis.gmaps.InfoWindowOptions
    var infoWindowOptions = {
      content:"<div style='text-align:left;'><font face='Verdana, Arial, Helvetica, sans-serif' size='-1'>You selected Path {WRS2PATH} and Row {WRS2ROW}.&nbsp;<br/><a href='http://35.8.163.123/access8/access6.asp?sensor=oli&Parow1={PAROW}&tilesNum=1&cloud=10' target='_blank'> Search landsat.org</a> for imagery at <br>this location."
      //content:"<div style='text-align:left;'><font face='Verdana, Arial, Helvetica, sans-serif' size='-1'>You selected Path {WRS2PATH} and Row {WRS2ROW}.&nbsp;<br/><a href='http://35.8.163.123/access8/access6.asp?sensor=etm&Parow1={PAROW}&tilesNum=1&cloud=10' target='_blank'> Search landsat.org</a> for imagery at <br>this location."
  };
  
    gOverlays = mapExtension.addToMap(fset,overlayOptions,infoWindowOptions);
    //var theSize = fset[0].displayFieldName;
    //var v = fset;
    //alert(v.geometryType);
    //alert(v.displayFieldName);
    //alert(v.features.length);
    //alert(v.features[0].geometry.length);
    //alert(v.features[0].geometry[0].getVertexCount());
    //alert(v.features[0].geometry[0].getVertex(0));
    //alert(fset.findResults[0].feature.geometry[0].getBounds());
    var theBounds = fset.findResults[0].feature.geometry[0].getBounds();
    var theSouthWest = theBounds.getSouthWest();
    var theSouthWestUrl = theSouthWest.toUrlValue(10);
    var theNorthEast = theBounds.getNorthEast();
    var theNorthEastUrl = theNorthEast.toUrlValue(10);
    var SouthWestArray = theSouthWestUrl.split(",");
    var NorthEastArray = theNorthEastUrl.split(",");
    var theCenterX = (parseFloat(SouthWestArray[0]) + parseFloat(NorthEastArray[0]))/2;
    var theCenterY = (parseFloat(SouthWestArray[1]) + parseFloat(NorthEastArray[1]))/2;
setMapLatLong(theCenterX,theCenterY);
    map.panTo(new GLatLng(theCenterX,theCenterY));

  }
  
  function cleanAll(gOverlay){
  mapExtension.removeFromMap(gOverlays);
  resetMapLatLong();
  map.setCenter(new GLatLng(10,0), 2);
  }
  
  
