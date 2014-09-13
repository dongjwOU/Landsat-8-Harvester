<% @LANGUAGE = VBScript %>
<%
Option Explicit
Response.Expires = 15
%>
<%' <!--#include virtual="/localhost/Map/sat_lib_g.asp"-->  %>

<%
'** ---------------------------------------------------------
'** Start Configuration Vars
'** ---------------------------------------------------------
Dim LSORGorg
Dim LSORGorgabrv
Dim LSORGcopyright
Dim LSORGdsnlsat8
Dim LSORGdsnlsat
Dim LSORGdsnmss
Dim LSORGserpath
Dim LSORGbuilderpath, LSORGlsatbuilderpath
Dim LSORGaccessurl
Dim LSORGbigimage
Dim LSORGbsrsiurl, LSORGotsurl
LSORGorg = "Global Observatory for Ecosystem Services"
LSORGorgabrv = "GOES"
LSORGcopyright = "Copyright &copy; 2008 GOES - Michigan State University"
'LSORGdsnlsat = "dsn=worldforest;uid=trfic;pwd=trfic;"
'LSORGdsnmss = "dsn=worldforest;uid=tmmss;pwd=tmmss;"
LSORGdsnlsat8 = "dsn=landsat;uid=sde;pwd=sde_equator;"
LSORGdsnlsat = "dsn=landsat;uid=sde;pwd=sde_equator;"
LSORGdsnmss = "dsn=landsat;uid=sde;pwd=sde_equator;"
'LSORGserpath = "http://www.landsat.org/cgi-bin/services/thumbnail/"
LSORGserpath = "http://www.bsrsi.msu.edu/cgi-bin/services/thumbnail/"
'LSORGlsatbuilderpath = "http://bsrsi.msu.edu/cgi-bin/access7builder.cgi/"
LSORGlsatbuilderpath = "http://35.8.163.100/cgi-bin/access7builder.cgi/"
'LSORGbuilderpath = "http://bsrsi.msu.edu/cgi-bin/access5builder.cgi/"
LSORGbuilderpath = "http://35.8.163.100/cgi-bin/access5builder.cgi/"
'LSORGaccessurl = "http://foliage.geo.msu.edu/access7/"
'LSORGaccessurl = "http://foliage.geo.msu.edu/beta/access_v_2/access7/"
LSORGaccessurl = "http://35.8.163.123/beta/access_v_2_1/access8/"
LSORGbigimage = "http://35.8.163.123/beta/access_v_2_1/"
' access7 uses: http://35.8.163.123/beta/access_v_2/access7/bigimage.asp?Picture=15/32/2011/LE70150322011306EDC00.jpg&ImageDate=November022011&sensor=etm
' access8 uses: http://foliage.geo.msu.edu/access_v_2_1/access8/bigimage.asp?Picture=2014/022/025/LC80220252014019LGN00.jpg&ImageDate=April112013&sensor=OLI
LSORGbsrsiurl = "http://bsrsi.msu.edu/"
LSORGotsurl = "http://35.8.163.100/ots/"

'** ---------------------------------------------------------
'** Start Constants
'** ---------------------------------------------------------
Dim CONSTstrmonths
CONSTstrmonths = Array("January","February","March","April","May","June","July","August","September","October","November","December")

'** ---------------------------------------------------------
'** Start Program Vars
'** ---------------------------------------------------------
Dim objLsatConn, objMSSConn
Dim objLsatConnOpen, objMSSConnOpen
Dim objRS, strQuery
Dim myimage, mydates, myparow, myyearday, mylocal, myentityid
Dim Pr1image(400), Pr1dates(400), Pr1yearday(400), Pr1local(400), Pr1entityid(400),sizePr1
Dim Pr2image(400), Pr2dates(400), Pr2yearday(400), Pr2local(400), Pr2entityid(400),sizePr2
Dim Pr3image(400), Pr3dates(400), Pr3yearday(400), Pr3local(400), Pr3entityid(400),sizePr3
Dim Pr4image(400), Pr4dates(400), Pr4yearday(400), Pr4local(400), Pr4entityid(400),sizePr4
Dim firstProw, secondProw, thirdProw, fourthProw
Dim Prow1Exist, Prow2Exist, Prow3Exist, Prow4Exist

Dim smyimage, smydates, smyparow, smyyearday, smylocal, smyentityid
Dim sPr1image(400), sPr1dates(400), sPr1yearday(400), sPr1local(400), sPr1sceneId(400),sesizePr1
Dim sPr2image(400), sPr2dates(400), sPr2yearday(400), sPr2local(400), sPr2sceneId(400),sesizePr2
Dim sPr3image(400), sPr3dates(400), sPr3yearday(400), sPr3local(400), sPr3sceneId(400),sesizePr3
Dim sPr4image(400), sPr4dates(400), sPr4yearday(400), sPr4local(400), sPr4sceneId(400),sesizePr4

Dim ipath,irow,icloud
Dim strpath, strprow, validrec
Dim numkont, recounts
Dim j
Dim price
Dim stryear, strmonthday, strmonth, strday, mymonth, thedate
Dim initParow
Dim curryear, currmonth, currday, strcurrmon, currdate
Dim startdatelon,enddatelon
Dim iStDate, iEndDate
Dim sStDate, sEndDate
Dim ilatitude, ilongitude, iStartMon, iStartYr, iEndMon, iEndYr

Dim builderpath, totpath, iSrt
Dim geoday, geomonth, geoyear, geozoomid, geodate
Dim StrQ
Dim begmonth, endmonth
Dim i,PATHS, ROWS, nextp, prevp, nextr, prevr
Dim nextrow, prevrow, nextpath, prevpath, iq_path, iq_row
Dim d,x
Dim allParows(100), tilesNum, tiles, nTiles, oneStrprow
Dim k, m
Dim titleData, lineTitle, selecData(10000), numRecdata, filename
Dim str, subr
Dim Texcom, Textab, Go, textfile
Dim strTextComa, strTextTab
Dim ind
Dim page, theColor, thePage, pageNum, Screen, pageback, pagefront, pNum
Dim keepParStr
Dim totrec
Dim kScene, scensInRow, iTitle, totSize, nPages, iDone, remain, Pages, recd
Dim strPatRows
Dim onlyOnce, strAddToOrd, start, beginPage, imageName
Dim sFirstProw ,sSecondProw,sThirdProw,sFourthProws, sCloud, srecd, sensorType, tableOPen
Dim sPr1,sPr2,sPr3,sPr4,strSensr, strSelPage

'** ---------------------------------------------------------
'** Initialize for the Text file
'** ---------------------------------------------------------
Prow1Exist ="TRUE"
Prow2Exist ="TRUE"
Prow3Exist ="TRUE"
Prow4Exist ="TRUE"

onlyOnce ="TRUE"
tableOPen = "FALSE"

sizePr1 = 0
sizePr2 = 0
sizePr3 = 0
sizePr4 = 0

sesizePr1 = 0
sesizePr2 = 0
sesizePr3 = 0
sesizePr4 = 0

'** ---------------------------------------------------------
'** One added to the size of Arrays
'** ---------------------------------------------------------
sPr1 = 0
sPr2 = 0
sPr3 = 0
sPr4 = 0

numRecdata = 0
Texcom =" "
Textab=" "
strTextComa =""
strTextTab = ""
strSelPage = ""

recd = 0


'** ---------------------------------------------------------
'** Check the Sensor
'** ---------------------------------------------------------
sensorType = Trim(Request.QueryString("sensor"))

If sensorType = "" Then
   sensorError
   Response.end
End If

If UCase(Left(sensorType,1)) <> "O" AND UCase(Left(sensorType,1)) <> "E" AND UCase(Left(sensorType,1)) <> "T" Then
   sensorError
   Response.end
End If

'** Added Landsat 8: sensor = OLI
If UCase(Left(sensorType,1)) = "O" Then
  strSensr = "Landsat 8"
ElseIf UCase(Left(sensorType,1)) = "E" Then
  strSensr = "Landsat 7"
Else
  strSensr = "Landsat 4 and Landsat 5"
End If



'** ---------------------------------------------------------
'** Put the pathrows in an array
'** ---------------------------------------------------------
tiles = Trim(Request.QueryString("tilesNum"))
nTiles = CInt(tiles)

firstProw=Trim(Request.QueryString("Parow1"))
secondProw=Trim(Request.QueryString("Parow2"))
thirdProw=Trim(Request.QueryString("Parow3"))
fourthProw=Trim(Request.QueryString("Parow4"))

'** ---------------------------------------------------------
'** scene table needs PathRows in numbers
'** ---------------------------------------------------------
If firstProw = "" Then
   sFirstProw = 0
Else
   sFirstProw = CLng(firstProw)
End If

If secondProw = "" Then
   sSecondProw = 0
Else
   sSecondProw = CLng(secondProw)
End If

If thirdProw = "" Then
   sThirdProw = 0
Else
   sThirdProw = CLng(thirdProw)
End If

If fourthProw = "" Then
   sFourthProws = 0
Else
   sFourthProws = CLng(fourthProw)
End If


'** ---------------------------------------------------------
'** Build the string to return Path and rows when a page is
'** selected.
'** ---------------------------------------------------------
If nTiles  = 1 Then
  strPatRows = "&" & "Parow1=" &firstProw
ElseIf nTiles  = 2 Then
  strPatRows = "&" & "Parow1=" &firstProw
  strPatRows = strPatRows & "&" & "Parow2=" &secondProw
ElseIf nTiles  = 3 Then
  strPatRows = "&" & "Parow1=" &firstProw
  strPatRows = strPatRows & "&" & "Parow2=" &secondProw
  strPatRows = strPatRows & "&" & "Parow3=" &thirdProw
ElseIf nTiles  = 4 Then
  strPatRows = "&" & "Parow1=" &firstProw
  strPatRows = strPatRows & "&" & "Parow2=" &secondProw
  strPatRows = strPatRows & "&" & "Parow3=" &thirdProw
  strPatRows = strPatRows & "&" & "Parow4=" &fourthProw
End If


If firstProw = "" Then
  Prow1Exist ="FALSE"
End If

If secondProw = "" Then
  Prow2Exist = "FALSE"
End If

If thirdProw = "" Then
  Prow3Exist ="FALSE"
End If

If fourthProw = "" Then
  Prow4Exist ="FALSE"
End If


'** ---------------------------------------------------------
'** Check if the first time calling this routine by checking the
'** Page number
'** ---------------------------------------------------------
pNum = Trim(Request.QueryString("Screen"))
If pNum ="" Then
   pageNum = 1
else
   pageNum = CInt(Trim(Request.QueryString("Screen")))
End If

iStartMon = Trim(Request.QueryString("StartMonth"))
iStartYr = Trim(Request.QueryString("StartYear"))
iEndMon = Trim(Request.QueryString("EndMonth"))
iEndYr = Trim(Request.QueryString("EndYear"))

If (iStartMon ="") Then
  iStartMon ="01"
End If

If (iStartYr ="") Then
  iStartYr ="1986"
End If

If (iEndMon ="") Then
  iEndMon = Month(Now())
End If

If (iEndYr ="") Then
  iEndYr = Year(Now())
End If

icloud = Trim(Request.QueryString("Cloud"))
If (icloud ="") Then
  icloud ="20"
  sCloud = 20
Else
  sCloud = CInt(icloud)
End If

iSrt = Trim(Request.QueryString("Sort"))
If (iSrt ="") Then
  iSrt = "DESC"
End If

iLatitude = Trim(Request.QueryString("initLatitude"))
iLongitude = Trim(Request.QueryString("initLongitude"))

'** ---------------------------------------------------------
'** Complete the string
'** ---------------------------------------------------------
strPatRows = strPatRows&"&Cloud="&icloud&"&StartMonth="&iStartMon&"&StartYear="
strPatRows = strPatRows&iStartYr&"&EndMonth="&iEndMon&"&EndYear="&iEndYr

'** ---------------------------------------------------------
'** Scenes are available from 1 day before
'** ---------------------------------------------------------
d=Now()
x = DateAdd("d", -1, d)

curryear =  Year(x)
currmonth = Month(x)
currday =  Day(x)
getmonth currmonth,strcurrmon
currdate = strcurrmon &" " & currday & ", " &curryear

'** ---------------------------------------------------------
'** Check the Path for Access7 or Access5
'** ---------------------------------------------------------
If UCase(Left(sensorType,1)) = "E" Then
'The next line gets modified to adjust to the move os accessbuilders
'from WF to ENGINE. It is done here and in Access5
   builderpath = LSORGlsatbuilderpath
Else
   builderpath = LSORGbuilderpath
End If
%>
<HTML>
<HEAD>
   <SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">
      function create_query_set(){
	  	theChoices = document.forms[1].elements[1];
	  	theChoiceSelected = theChoices.options[theChoices.selectedIndex].value;
	  	theQuery = document.forms[1].elements[2].value;
	    if (theChoiceSelected=="A") alert("Select format before submitting your request");
	    else {
               var aLoc = "<%= LSORGaccessurl%>text.asp?";
	       aLoc = aLoc +"format="+theChoiceSelected+"&"+theQuery;
	       //window.open(aLoc,'query','screenX=0,screenY=0,width=450,height=250,location=no,menubar=no,satus=no,personalbar=no,toolbar=no,scrollbars=yes,resizable=yes');
		alert("This option is temporarily disabled")
	    }
      }

      function newWindow(strip) {
	    StripWindow = window.open(strip,'StripBuilder','width=285,height=780,scrollbars');
	    StripWindow.focus();
      }

      function newImageWindow(url) {
            BigImageWindow = window.open(url,'ViewImage','width=860,height=865,scrollbars');
            BigImageWindow.focus();
      }

      function browse(id) {
            BrowseWindow = window.open('<%= LSORGbsrsiurl%>cgi-bin/gz/' +id,'tmssb','scrollbars=no,resizable=no,width=663,height=735');
            BrowseWindow.focus()
      }

      function MM_findObj(n, d) { //v3.0
        var p,i,x;
        if (!d) d=document;
        if ((p=n.indexOf("?"))>0&&parent.frames.length) {
          d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);
        }
        if (!(x=d[n])&&d.all) x=d.all[n];
        for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
        for (i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
        return x;
      }

      function MM_swapImage() { //v3.0
        var i,j=0,x,a=MM_swapImage.arguments;
        document.MM_sr=new Array;
        for (i=0;i<(a.length-2);i+=3) {
          if ((x=MM_findObj(a[i]))!=null) {
            document.MM_sr[j++]=x;
            if (!x.oSrc) x.oSrc=x.src;
            x.src=a[i+2];
          }
        }
      }

      function MM_swapImgRestore() { //v3.0
	var i,x,a=document.MM_sr;
        for (i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
      }

      function refreshMap(){}

      function otswin(otsstr) {
        window.open('<%= LSORGotsurl%>ots.php?'+otsstr,'OTS','scrollbars=yes,resizable=yes,menubar=yes,width=675,height=600');
//	window.open('http://35.8.163.123/access7/ots.htm','OTS','scrollbars=yes,resizable=yes,menubar=yes,width=675,height=600');
      }

   </SCRIPT>
   <TITLE>Results</TITLE>
</HEAD>
<BODY onload="self.focus()">
    <SCRIPT language="JavaScript">
       //sets a layer with the banner
       var IE4 = (document.all && !document.getElementById) ? true : false;
	   var NS4 = (document.layers) ? true : false;
	   var NS5 = (document.layers) ? true : false;
	   var IE5 = (document.all && document.getElementById) ? true : false;
	   var N6 = (document.getElementById && !document.all) ? true : false;

	   var ancho;
	   var alto = 240
	   if (NS4) {
	     ancho = parseInt((window.innerWidth - 273)/2);
	     document.writeln('<layer name="blockDiv" left=' + ancho + ' top=' + alto +' width=68 height=68 >');
	     document.writeln('<img src="images/loadData.gif">');
	     document.writeln('</layer>');
	   }
	   else {
	     ancho = parseInt((document.body.clientWidth -273)/2);
	     document.writeln('<div ID="blockDiv" style="position:absolute; left:' + ancho + 'px; top:' + alto + 'px; width:68 px; height:68 px;' +  '">');
	     document.writeln('<img src="images/loadData.gif">');
	     document.writeln('</div>');
       }

    </SCRIPT>

    <table width="750" border="0" cellspacing="1" cellpadding="1" align="center">
	  <tr>
		 <td>
		    <table width="100%" border="0" cellspacing="1" cellpadding="1" align="center">
		       <tr>

          <% If sensorType = "ETM" Then %>
              <td width="33%"><div align="left"><i>
                <font face="Verdana, Arial, Helvetica, sans-serif" size="1">
                  <a href="http://www.landsat.org/ordering_etm.html" target="_blank">
                    Information on ordering ETM+ data</a></font></i></div></td>
              <td width="34%"><div align="center"><a href="http://landsat.org/"><img src="images/landsatdotorgNEWsmall.gif" alt="To Landsat.org Home" border="0"></a></div></td>
              <td width="33%"><div align="right"><i>
                <font face="Verdana, Arial, Helvetica, sans-serif" size="1">
                    <font color="#FF0000">Notice:</font> Data acquired after July 14, 2003 where collected in<a href="http://landsat.usgs.gov/Landsat_7_ETM_SLC_off_data.php" target="_blank"> SLC-Off mode</a>.</font></i></div></td>

          <% ElseIf sensorType = "OLI" Then %>
              <td width="33%"><div align="left"><i>
                <font face="Verdana, Arial, Helvetica, sans-serif" size="1">
                  <a href="http://www.landsat.org/ordering_<%= sensorType%>.html" target="_blank">
                    Information on ordering <%= sensorType%> data</a></font></i></div></td>
              <td width="34%"><div align="center"><a href="http://landsat.org/"><img src="images/landsatdotorgNEWsmall.gif" alt="To Landsat.org Home" border="0"></a></div></td>
              <td width="33%"><div align="right"><i>
                <font face="Verdana, Arial, Helvetica, sans-serif" size="1">
                    <font color="#FF0000"></font> <a href="" target="_blank"> </a></font></i></div></td>
          <% Else %>
              <td width="33%"><div align="left"><i>
                <font face="Verdana, Arial, Helvetica, sans-serif" size="1">
                  <a href="http://www.landsat.org/ordering_etm.html" target="_blank">
                    Information on ordering <%= sensorType%> data</a></font></i></div></td>
              <td width="34%"><div align="center"><a href="http://landsat.org/"><img src="images/landsatdotorgNEWsmall.gif" alt="To Landsat.org Home" border="0"></a></div></td>
              <td width="33%"><div align="right"><i>
                <font face="Verdana, Arial, Helvetica, sans-serif" size="1">
                    <a href="" target="_blank"> </a></font></i></div></td>
          <% End If %>
          
		       </tr>
		    </table>
		 </td>
	  </tr>
	  <tr>
	     <td>
	        <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="-3" color="#0000CC"><i>
		        Powered by <% =strSensr%> with StripBuilder v1.0 and Online Ordering<br>
                        <%= LSORGorg %>
                        </i></font></div>
		 </td>
	</tr></table>

	<table width="750" border="0" cellspacing="1" cellpadding="1" align="center">
	  <tr bgcolor="#3366cc">
	    <td>
	       <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3" color="#ffffff">
		       <% =strSensr %> Scenes Available as of <%= currdate %></font></div>
		</td>
	  </tr><br>
    </table>




    <table width="650" border="0" cellspacing="1" cellpadding="1" align="center" ><br><br>
	   <tr>
	      <td><center>
		  	  <FORM>
		  		  <INPUT TYPE="button" VALUE="Search Again" onClick="window.open(this.href,'_blank', 'width=700, height=300');">
				  <!										onclick="opener.focus()">
		  	  </FORM></center>
		    </td>

        <td><center>
		  	   <FORM name="text_query">
		  	     <INPUT TYPE="hidden" name= "texdata" value=" ">
		  			  &nbsp;&nbsp;Change Landsat satellite:
		  		  	  <select name="theChoice">
						 <option value="MSS"> Landsat 4/5 MSS </option>
		  		 	     <option value="TM"> Landsat 4/5 TM </option>
		  		 	     <option value="ETM"> Landsat 7 ETM+ </option>
		  		 		 <option value="OLI" selected> Landsat 8 OLI/TIRS </option>
		  		 	  </select>
		  		 <INPUT TYPE="hidden" name= "texdata" value="<!% =Request.QueryString%>">
		  		 <INPUT TYPE="button" VALUE="Go" href="http://landsat.org" onClick="window.open(this.href,'_blank', 'width=700, height=300');">
				 <! INPUT TYPE="button" VALUE="Go" onclick="create_query_set();">
		  	   </FORM></center>
		    </td>

	      <td><center>
		      <FORM>
		    	 <INPUT TYPE="button" VALUE="Close this window" onClick="self.close()">
		  	  </FORM></center>
	      </td>
	   </tr>
    </table><br>


<%
 ' =======================================================================
 '   -------------------- Begin Main Processing -----------------------
 ' =======================================================================
  '** ------------------------------------------------------------
  '** Open the database connections
  '** ------------------------------------------------------------
  set objLsatConn = Server.CreateObject("ADODB.Connection")
  objLsatConn.Open LSORGdsnlsat
  set objMSSConn = objLsatConn
  objLsatConnOpen = 1
  objMSSConnOpen = 0

  if StrComp(LSORGdsnlsat,LSORGdsnmss) <> 0 Then
    set objMSSConn = Server.CreateObject("ADODB.Connection")
    objMSSConn.Open LSORGdsnmss
    objMSSConnOpen = 1
  End If

  Response.Flush
  '** ------------------------------------------------------------
  '** Get the total database count
  '** ------------------------------------------------------------
  getDbcount(strSensr)

  strprow = allParows(pageNum)
  validrec = 0
  If (strprow <>"") Then
    irow = Right(strprow,3)
    ipath = Left(strprow,3)
  End If

  ilatitude="40.3631"
  ilongitude="-84.0824"

  getmonth iStartMon,begmonth
  startdatelon = begmonth & " " & iStartYr
  getmonth iEndMon,endmonth
  enddatelon = endmonth & " " & iEndYr

  'iStDate = "'" & "01" & "-" & Left(begmonth,3) & "-" & Right(iStartYr,2) & "'"
  'iEndDate = "'" & "28" & "-" & Left(endmonth,3) & "-" & Right(iEndYr,2) & "'"

  iStDate = "'" & "01" & "-" & Left(begmonth,3) & "-" & iStartYr& "'"
  iEndDate = "'" & "28" & "-" & Left(endmonth,3) & "-" & iEndYr & "'"

  sStDate = "01" & "/" & Left(begmonth,3) & "/" & iStartYr
  sEndDate = "28" & "/" & Left(endmonth,3) & "/" & iEndYr

  '** ------------------------------------------------------------
  '** Get OLI or ETM data 
  '** ------------------------------------------------------------
  If Left(sensorType,1) = "O" OR Left(sensorType,1) = "o" Then
    GetOLIdata firstProw,Pr1entityid,Pr1local,Pr1dates,Pr1yearday,Pr1image,sizePr1
    GetOLIdata secondProw,Pr2entityid,Pr2local,Pr2dates,Pr2yearday,Pr2image,sizePr2
    GetOLIdata thirdProw,Pr3entityid,Pr3local,Pr3dates,Pr3yearday,Pr3image,sizePr3
    GetOLIdata fourthProw,Pr4entityid,Pr4local,Pr4dates,Pr4yearday,Pr4image,sizePr4
  ElseIf Left(sensorType,1) = "E" OR Left(sensorType,1) = "e" Then
    GetETMdata firstProw,Pr1entityid,Pr1local,Pr1dates,Pr1yearday,Pr1image,sizePr1
    GetETMdata secondProw,Pr2entityid,Pr2local,Pr2dates,Pr2yearday,Pr2image,sizePr2
    GetETMdata thirdProw,Pr3entityid,Pr3local,Pr3dates,Pr3yearday,Pr3image,sizePr3
    GetETMdata fourthProw,Pr4entityid,Pr4local,Pr4dates,Pr4yearday,Pr4image,sizePr4
  Else
    '** ------------------------------------------------------------
    '** Get the TM data from EDC_TM databas table for all four Path rows
    '** ------------------------------------------------------------
    GetParowArrByDB firstProw,Pr1entityid,Pr1local,Pr1dates,Pr1yearday,Pr1image,sizePr1
    GetParowArrByDB secondProw,Pr2entityid,Pr2local,Pr2dates,Pr2yearday,Pr2image,sizePr2
    GetParowArrByDB thirdProw,Pr3entityid,Pr3local,Pr3dates,Pr3yearday,Pr3image,sizePr3
    GetParowArrByDB fourthProw,Pr4entityid,Pr4local,Pr4dates,Pr4yearday,Pr4image,sizePr4

    '** ------------------------------------------------------------
    '** Get the TM data from SCENE databas table for all four Path rows
    '** ------------------------------------------------------------
    GetSceneData 1,sPr1sceneId,sPr1dates,sPr1yearday,sPr1image,sPr1local,sesizePr1
    GetSceneData 2,sPr2sceneId,sPr2dates,sPr2yearday,sPr2image,sPr2local,sesizePr2
    GetSceneData 3,sPr3sceneId,sPr3dates,sPr3yearday,sPr3image,sPr3local,sesizePr3
    GetSceneData 4,sPr4sceneId,sPr4dates,sPr4yearday,sPr4image,sPr4local,sesizePr4

    '** ------------------------------------------------------------
    '** Add the SCENE data arrays to the EDC_TM data arrays **
    '** ------------------------------------------------------------
    AddDataArrays
  End If

  '** ------------------------------------------------------------
  '** Show the error if there is no data for that Path Row
  '** ------------------------------------------------------------
  If  pageNum = 1 Then
    If Prow1Exist = "TRUE" AND  sizePr1 = -1 Then
      showError firstProw
    End If

    If Prow2Exist = "TRUE" AND sizePr2 = -1 Then
      showError secondProw
    End If

    If Prow3Exist = "TRUE" AND sizePr3 = -1 Then
      showError thirdProw
    End If

    If Prow4Exist = "TRUE" AND sizePr4 = -1 Then
      showError fourthProw
    End If
  End If

  '** ------------------------------------------------------------
  '** Building the Page and display the scenes
  '** ------------------------------------------------------------
  iTitle = 1
  scensInRow = 0
  iDone = "FALSE"
  Pages = 0
  For i =0 to sizePr1
    myparow = firstProw
    myentityid = Pr1entityid(i)
    mylocal = Pr1local(i)
    mydates = Pr1dates(i)
    myyearday = Pr1yearday(i)
    myimage = Pr1image(i)
    kScene = kScene +1

    If (pageNum = 1) OR (pageNum -1 = Pages ) Then
      If iTitle = 1 Then
	iTitle = 0
	ShowTitle myparow
      End If
      showScenes myparow,myentityid,mylocal,mydates,myyearday,myimage,iTitle,scensInRow
      If kScene = 20 Then
        iDone = "TRUE"
        Exit For
      End If
    End If

    If kScene = 20 Then
      kScene = 0
      Pages = Pages + 1
    End If
  Next

  '** ------------------------------------------------------------
  '** Check the second Pathrow
  '** ------------------------------------------------------------
  If iDone = "FALSE" Then
    iTitle = 1
    scensInRow = 0

    For i =0 to sizePr2
      myparow = secondProw
      myentityid = Pr2entityid(i)
      mylocal = Pr2local(i)
      mydates = Pr2dates(i)
      myyearday = Pr2yearday(i)
      myimage = Pr2image(i)

      kScene = kScene +1
      If kScene = 20 Then
	kScene = 0
	Pages = Pages + 1
      End If

      If (pageNum -1 = Pages ) Then
	If iTitle = 1 Then
          iTitle = 0
	  ShowTitle myparow
        End If

        showScenes myparow,myentityid,mylocal,mydates,myyearday,myimage,iTitle,scensInRow
        If kScene = 20 Then
          iDone = "TRUE"
          Exit For
        End If

      End If
    Next
  End If

  '** ------------------------------------------------------------
  '** Check the third Pathrow
  '** ------------------------------------------------------------
  If iDone = "FALSE" Then
    iTitle = 1
    scensInRow = 0
    For i = 0 to sizePr3
      myparow = thirdProw
      myentityid = Pr3entityid(i)
      mylocal = Pr3local(i)
      mydates = Pr3dates(i)
      myyearday = Pr3yearday(i)
      myimage = Pr3image(i)

      kScene = kScene +1
      If kScene = 20 Then
	kScene = 0
	Pages = Pages + 1
      End If

      If (pageNum - 1 =Pages) Then
	If iTitle = 1 Then
	  iTitle = 0
	  ShowTitle myparow
	End If

	showScenes myparow,myentityid,mylocal,mydates,myyearday,myimage,iTitle,scensInRow
	If kScene = 20 Then
	  iDone = "TRUE"
	  Exit For
	End If
      End If
    Next
  End If

  '** ------------------------------------------------------------
  '** Check the fourth Pathrow
  '** ------------------------------------------------------------
  If iDone = "FALSE" Then
    iTitle = 1
    scensInRow = 0
    For i = 0 to sizePr4
      myparow = fourthProw
      myentityid = Pr4entityid(i)
      mylocal = Pr4local(i)
      mydates = Pr4dates(i)
      myyearday = Pr4yearday(i)
      myimage = Pr4image(i)

      kScene = kScene +1
      If kScene = 20 Then
	kScene = 0
	Pages = Pages + 1
      End If

      If (pageNum -1=Pages) Then
	If iTitle = 1 Then
          iTitle = 0
          ShowTitle myparow
	End If

	showScenes myparow,myentityid,mylocal,mydates,myyearday,myimage,iTitle,scensInRow
	If kScene = 20 OR i=sizePr4 Then
	  Exit For
	End If
      End If
    Next
  End If
%>

  </TR></TABLE>
  <FORM NAME="final" METHOD="POST">
     <INPUT TYPE="hidden" NAME="storedatcom" VALUE="<%= strTextComa%>">
  	 <INPUT TYPE="hidden" NAME="storedattab" VALUE="<%= strTextTab%>">
  </FORM>

<%
  '** ------------------------------------------------------------
  '** Show Pages Menu
  '** ------------------------------------------------------------
  '** Add 1 to each size because it starts from
  '** ------------------------------------------------------------
  If sizePr1<0 Then
    sPr1 = 1
  End If

  If sizePr2<0 Then
    sPr2 = 1
  End If

  If sizePr3<0 Then
    sPr3 = 1
  End If

  If sizePr4<0 Then
    sPr4 = 1
  End If

  totSize =sizePr1 + sizePr2 + sizePr3 + sizePr4 + sPr1 + sPr2 + sPr3 + sPr4
  If totSize <= 20 Then
    nPages = 1
  End If

  If totSize > 20 Then
    remain = totSize Mod 20
    If remain = 0 Then
      nPages = totSize/20
    Else
      nPages = (totSize - remain)/20 + 1
    End If
    strSelPage = "Select Pages"
  End If

  thecolor = "Magenta"
%>

<% If nPages > 1 Then %>
        <table width="750" border="0" cellspacing="1" cellpadding="1" align="center">
           <tr><td align="center"> <br><br>

<%
   For m = 1 to nPages
     If m = pageNum Then
       thecolor = "Magenta"
     Else
       thecolor = "#082984"
     End If

     pageback = pageNum
     pagefront = pageNum

     If pageback <=1 Then
       pageback = 1
     Else
       pageback = pageNum - 1
     End If

     If pagefront >=nPages Then
       pagefront = nPages
     Else
       pagefront = pageNum + 1
     End If

     If m = 1 Then
%>

		       <A HREF="<%= LSORGaccessurl%>access6.asp?sensor=<%= sensorType%>&tilesNum=<%=tiles%><%= strPatRows%>&Screen=<%= pageback%>"> <B> <font color="<%=thecolor%>"> </font></B>
		   	     <img src="images/Left.gif" width="15" height="15" border=0></A> </b>&nbsp;
	        <% End If %>
	           <A HREF="<%= LSORGaccessurl%>access6.asp?sensor=<%= sensorType%>&tilesNum=<%=tiles%><%= strPatRows%>&Screen=<%=m%>"> <B><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="<%=thecolor%>"> <%=m%> </font></B>
	            </A> </b>&nbsp;
	        <% If m = nPages Then %>
	           <A HREF="<%= LSORGaccessurl%>access6.asp?sensor=<%= sensorType%>&tilesNum=<%=tiles%><%= strPatRows%>&Screen=<%=pagefront%>"> <B><font color="<%=thecolor%>"></font></B>
	             <img src="images/Right.gif" width="15" height="15" border=0></A> </b>































<%
     End If
   Next
%>

           </td></tr>
           <tr><td align="center">
	         <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#082984"><b><% =strSelPage%></b></font></div><br>
	       </td></tr>
        </table><br>
<%
  End If '*** FOR WHICH IF
%>

    <TABLE width="750" border="0" cellspacing="1" cellpadding="1" align="center">
      <TR bgcolor="#3366CC">
        <TD>
          <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#ffffff"><%= LSORGcopyright %></font></div>
        </TD>
      </TR>
    </TABLE>

</BODY>
	<SCRIPT TYPE="text/javascript" LANGUAGE="JavaScript">
	setTimeout("refreshMap()",5000);
	//alert("done");

	var IE4 = (document.all && !document.getElementById) ? true : false;
	var NS4 = (document.layers) ? true : false;
	var IE5 = (document.all && document.getElementById) ? true : false;
	var N6 = (document.getElementById && !document.all) ? true : false;

    var NS5 = (document.layers) ? true : false;

	//hide banner
	if (NS4) document.layers['blockDiv'].visibility = "hide";
    if (N6) document.getElementById('blockDiv').style.visibility = "hidden";
    else document.all['blockDiv'].style.visibility = "hidden";

   </SCRIPT>

<%
  '** ------------------------------------------------------------
  '** Close the database connections
  '** ------------------------------------------------------------
  if objLsatConnOpen = 1 Then
    objLsatConn.close
    objLsatConnOpen = 0
    if StrComp(LSORGdsnlsat,LSORGdsnmss) <> 0 Then
      if objMSSConnOpen = 1 then
        objMSSConn.close
        objMSSConnOpen = 0
      End If
    End If
    Set objLsatConn = Nothing
    Set objMSSConn = Nothing
  End If
%>
</HTML>


<%
' ==================================================================
' @fn getmonth(currmont,strcurrmon)
'
' This subroutine converts the month string number to
' its name.
'
' @param currmonth   Month in number
' @param strcurrmon  Month name
'
' ==================================================================
Sub getmonth(currmonth,strcurrmon)
  strcurrmon = CONSTstrmonths(currmonth-1)
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn getDbcount()
'
' This procedure Get the Database count records.
' ==================================================================
Sub getDbcount(sensor_type)
   set objRS  = Server.CreateObject("ADODB.Recordset")
   set objRS.ActiveConnection = objLsatConn
   If sensor_type = "Landsat 8" Then
     Set objRS = objLsatConn.Execute("SELECT STR(COUNT(*)) AS numkont FROM SCENES_OLI")
   ElseIf sensor_type = "Landsat 7" Then
     Set objRS = objLsatConn.Execute("SELECT STR(COUNT(*)) AS numkont FROM SCENE2")
   ElseIf sensor_type = "Landsat 4 and Landsat 5" Then
     Set objRS = objLsatConn.Execute("SELECT STR(COUNT(*)) AS numkont FROM EDC_TM")
    End If
   recounts = objRS("numkont")
   objRS.close
   Set objRS = Nothing
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn GetParowArrByDB(strprow,mmyentityid,mmylocal,mmydates,
'                                          mmyyearday,mmyimage,recd)
'
' This Sub procedure builds four Pathrow arrays. Each array belongs
' to pathrow.
' ==================================================================
Sub GetParowArrByDB(strprow,mmyentityid,mmylocal,mmydates,mmyyearday,mmyimage,recd)
    set objRS  = Server.CreateObject("ADODB.Recordset")
    set objRS.ActiveConnection = objLsatConn

    '** ------------------------------------------------------------
    '** Get the Data records from the Database
    '** ------------------------------------------------------------
     StrQ = "SELECT ENTITY_ID,TO_CHAR(YEARDAY) AS YRDAY,BROWSEURL,TO_CHAR(LOCAL) AS LOCS,TO_CHAR(acquired,'YYYYMMDD') AS DATES FROM EDC_TM WHERE PAROW = '"&strprow&"'"
     StrQ = StrQ & "AND  ACQUIRED BETWEEN "&iStDate&" AND "&iEndDate&" "
     StrQ = StrQ & "AND CLOUD <='"&icloud&"' ORDER BY acquired "&iSrt&" "
     Set objRS = objLsatConn.Execute(StrQ)

     While Not(objRS.EOF)

       'Response.Write objRS("PAROW") &"   " & objRS("DATES") &"   " &objRS("LOCS")  &"   " &objRS("BROWSEURL") & "<BR>" & VbCrLf

        mmyentityid(recd) = objRS("ENTITY_ID")
        mmylocal(recd) = objRS("LOCS")
        mmydates(recd) = objRS("DATES")
        mmyyearday(recd) = objRS("YRDAY")
        mmyimage(recd) = objRS("BROWSEURL")

        objRS.MoveNext
        recd = recd + 1
    Wend

    '** ------------------------------------------------------------
    '** The loopadded one extra record
    '** ------------------------------------------------------------
    recd = recd - 1

    objRS.close
    Set objRS = Nothing
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn showError(myparow)
'
' This procedure shows the error message when there is no record
' for a path in the Database.
' ==================================================================
Sub showError (myparow)
    irow = Right(myparow,3)
	ipath = Left(myparow,3)
  %>

     <table width="750" border="0" cellspacing="1" cellpadding="1" align="center"><tr bgcolor="#3366CC"><td>
	       <div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#ffffff">
	           No records match for Path: <%= ipath%> Row: <%= irow%> with Cloud Cover: 0 - <%=icloud%>% <br>
	           <%= startdatelon%>&nbsp;&nbsp;to&nbsp;&nbsp;<%=enddatelon%> </font></div></td></tr></table><br>

     <% If onlyOnce ="TRUE" Then %>
        <% onlyOnce ="FALSE" %>

	       <div style="position:relative; left:10; width:750; color:Black">
	           <blockquote><p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
	           Tips: Be sure your date range is plausable. This database is updated nightly but can only
	           retreive browse products 2 days after acquisition. Be sure the Path/Row combination makes sense
	           Landsat satellites do not generally collect imagery over the ocean. Acceptable numbers for "Path"
	         (the ground trace of an orbit) are 1 - 233 with "Row" ranging from 1 - 248. Also consider increasing the % cloud cover for your search.
	          </blockquote>
           </font></div>

     <% End If%>
<%
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn showScenes(myparow,myentityid,mylocal,mydates,myyearday,
'                                                  myimage,iTitle,j)
'
' This procedure shows the scenes on the screen
' ==================================================================
Sub showScenes (myparow,myentityid,mylocal,mydates,myyearday,myimage,iTitle,j)
   Dim strDate,monthNum, fromJPG, accessETM, strEntityid, accesslocTM, accessOLI

   accessETM = "FALSE"
   accesslocTM = "FALSE"
   accessOLI = "FALSE"

   If UCase(Left(sensorType,1)) = "O" Then
         accessOLI = "TRUE"
         strpath = Left(myimage,Len(myimage))
         stryear = Left(mydates,4)
         strmonthday = Right(mydates,4)
         strmonth = Left(strmonthday,2)
         strday = Right(strmonthday,2)
         getmonth strmonth,mymonth
         thedate = mymonth & " " & strday & ", " & stryear
         strDate = mymonth & strday & stryear

        imageName = Right(myimage,Len(myimage)-47) 
        '39'

         geoday = strday
   geomonth = strmonth
   geoyear = Right(stryear,2)
         geozoomid = "e" & myparow & geomonth & geoday & geoyear & "2"
         geodate = stryear &"-" &strmonth &"-" &strday
         'myentityid = "e" & myentityid

   ElseIf UCase(Left(sensorType,1)) = "E" Then
         accessETM = "TRUE"
         strpath = Left(myimage,Len(myimage))
         stryear = Left(mydates,4)
         strmonthday = Right(mydates,4)
         strmonth = Left(strmonthday,2)
         strday = Right(strmonthday,2)
         getmonth strmonth,mymonth
         thedate = mymonth & " " & strday & ", " & stryear
         strDate = mymonth & strday & stryear

         If Len(myimage) > 83 Then
           imageName = Right(myimage,Len(myimage)-83)
         Else
           If Len(myimage) > 39 Then
             imageName = Right(myimage,Len(myimage)-39)
             Else imageName= "null.jpg"
           End If
         End If

         geoday = strday
	 geomonth = strmonth
	 geoyear = Right(stryear,2)
         geozoomid = "e" & myparow & geomonth & geoday & geoyear & "2"
         geodate = stryear &"-" &strmonth &"-" &strday
         'myentityid = "e" & myentityid
   Else
   '** ------------------------------------------------------------
   '** Sensor is TM
   '** ------------------------------------------------------------
      fromJPG = "FALSE"
      '** ------------------------------------------------------------
      '** Data coming from (EDC_TM)
      '** ------------------------------------------------------------
      If Right(myimage,3)="jpg" Then
         strpath = Left(myimage,Len(myimage))
         stryear = Left(mydates,4)
         strmonthday = Right(mydates,4)
         strmonth = Left(strmonthday,2)
         strday = Right(strmonthday,2)
         getmonth strmonth,mymonth
         thedate = mymonth & " " & strday & ", " & stryear
         strDate = mymonth & strday & stryear
         imageName = Right(myimage,Len(myimage)-83)
         geoday = strday
	 geomonth = strmonth
	 geoyear = Right(stryear,2)
         geozoomid = "t" & myparow & geomonth & geoday & geoyear & "2"
         geodate = stryear &"-" &strmonth &"-" &strday
      Else
        '** ------------------------------------------------------------
        '** Data coming from (tmmss_SCENE)
        '** ------------------------------------------------------------
         accesslocTM = "TRUE"
         strday = Left(mydates,2)
	 stryear = Right(mydates,4)
	 remain = Left(mydates,6)
	 mymonth = Right(remain,3)
	 GetFullMonth mymonth,strmonth,monthNum
	 thedate = strmonth & " " & strday & ", " & stryear
         strDate = strmonth & strday & stryear
         imageName = Right(myimage,Len(myimage)-50)
         geoday = strday
	 geomonth = monthNum
	 geoyear = Right(stryear,2)
	 geozoomid = "t" & myparow & geomonth & geoday & geoyear & "2"
	 geodate = stryear &"-" &monthNum &"-" &strday
         geodate = stryear &"-" &monthNum &"-" &strday
      End If
   End If
   'strDate = strmonth & strday & stryear
   totpath = builderpath & myparow & stryear & myyearday

   If Len(myyearday)=1 Then
      myyearday = "00" & myyearday
   End If

   If Len(myyearday)=2 Then
      myyearday = "0" & myyearday
   End If

   If j = 0 Then
%>
	  <TABLE width="750" border="0" cellspacing="1" cellpadding="1" align="center">
	  <TR>
<%
      tableOPen = "TRUE"
   End If
   If j = 4 Then
%>
        </TR></TABLE>
	    <TR><HR width="750" color="#A1A1A1" noshade> </TR>
        <TABLE width="750" border="0" cellspacing="1" cellpadding="1" align="center">
        <TR>
<%
      j =0
      tableOPen = "TRUE"
   End If

   j = j+1

%>

<%' If UCase(Left(sensorType,1)) = "T" Then %>
     <TD width="5%"><div align="center"> <a href="javascript:newImageWindow('<%= LSORGbigimage%>bigimage.asp?Picture=<%= imageName%>&ImageDate=<%=strDate%>&sensor=<%=sensorType%>');">
       <IMG SRC="<%=myimage%>" WIDTH=150 HEIGHT=136 BORDER=0 ALT="Click to enlarge image."></a><BR>
          <font size="2" face="Verdana, Arial, Helvetica, sans-serif">
           <a href="javascript:newWindow('<%=totpath%>');"> <%= thedate%>
           </a><BR>
<%' End If%>

<%
   If mylocal = "0" Then
      If accessETM = "TRUE" OR accessOLI = "TRUE" Then
      	'If stryear >= 2003 Then
      	'		price = "$275"
     	'		strEntityid = myentityid & "&s=ETM%2b"
     	'	If stryear = "2003" Then
     	'		If strmonth = 10 or strmonth = 07 or strmonth = 08 or strmonth = 09 or strmonth = 11 or strmonth = 12 Then
     	'			price = "$275"
     	'		Else
     	'			price = "$600"
     	'		End If
      	'	End If
      	'Else
       ' price = "$600"
       ' strEntityid = myentityid & "&s=ETM%2b"
       ' End If

       	price = "$50"
      If accessOLI = "True" Then
		    strEntityid = myentityid & "&s=OLI%2b"
      ElseIf accessETM = "True" Then
        strEntityid = myentityid & "&s=ETM%2b"
      End If

      Else
	    'price = "$450"
	    price = "$50"
	    strEntityid = myentityid
	  End If
%>

      <SMALL> <%= price%></SMALL><BR>
      <A HREF="javascript:otswin('add=<%=myentityid%>');">Add to Order</A><BR>
<%
   Else
    If accessOLI = "TRUE" Then
      price = "$50"
      strEntityid = myentityid & "&s=OLI%2b" & "&loc=1"
    ElseIf accessETM = "TRUE" Then
	    price = "$50"
	    strEntityid = myentityid & "&s=ETM%2b" & "&loc=1"
	 Else
	    price = "$25"
	    strEntityid = myentityid
	    If accesslocTM = "TRUE" Then
	       strEntityid = myentityid & "&cl=" & icloud & "&s=TM"
	    End If
	 End If

%>
     <SMALL> <SPAN STYLE="color:red;"><%= price%></SPAN></SMALL><BR>
     <A HREF="javascript:otswin('add=<%=strEntityid%>');">Add to Order</A><BR>
	<!--  <A HREF="javascript:browse('<%=geozoomid%>');"><small><SPAN STYLE="color:red;">GeoZoom</SPAN></small></A> -->
<%
   End If
%>

	<INPUT TYPE="hidden" NAME="region" VALUE="Global Acquisitions">
	<INPUT TYPE="hidden" NAME="area" VALUE="Access7 Global-<%=price%>">
	<INPUT TYPE="hidden" NAME="tile" VALUE="2">
	<INPUT TYPE="hidden" NAME="path" VALUE="<%=ipath%>">
	<INPUT TYPE="hidden" NAME="row" VALUE="<%=irow%>">
	<INPUT TYPE="hidden" NAME="month" VALUE="<%=geodate%>">
	<INPUT TYPE="hidden" NAME="day" VALUE="">
	<INPUT TYPE="hidden" NAME="year" VALUE="">
	<INPUT TYPE="hidden" NAME="sensor" VALUE="ETM+">
	</FORM>

    </font></DIV></TD>

<%
   strTextComa = strTextComa & ipath &"           " & irow & "          " & icloud & "          " &thedate &" ,"
   strTextTab = strTextTab & ipath &"          " & irow & "          " & icloud & "          " &thedate &"	"


  End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn ShowTitle(myparow)
'
' This procedure shows the scenes on the screen.
' ==================================================================
Sub ShowTitle (myparow)
  Dim row,path

  row = Right(myparow,3)
  path = Left(myparow,3)

  '** ------------------------------------------------------------
  '** The Table should be closed if it is open
  '** ------------------------------------------------------------
  If tableOPen = "TRUE" Then
       tableOPen = "FALSE"
%>
     </TR></TABLE>
<%
  End If
%>
	 <TABLE width="750" border="0" cellspacing="1" cellpadding="1" align="center">
		 <tr bgcolor="#3366cc">
		  	 <td><div align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="2" color="#ffffff">
		  	 	  Path: <%= path%> &nbsp;&nbsp;&nbsp;Row: <%= row%> &nbsp;&nbsp;&nbsp;Cloud Cover: 0 - <%= icloud%>% <br>
		  	  	  <%= startdatelon%> &nbsp;to &nbsp;<%= enddatelon%><br>
		  	  	  Database Records Searched: <%= recounts%>
	 </font></div></td></tr></TABLE>

<%
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn GetYearDay(allDate,size,yrDays)
'
' This subroutine calculates the Yearday from Table scene
' (tmmss) for Leap Years and Non Leap years.
' ==================================================================
Sub GetYearDay(allDate,size,yrDays)
  Dim currDay,aMonth,year,i, remain, yearDay

  '** ------------------------------------------------------------
  '** Calculate the Yearday for Leap Years and Non Leap Years
  '** ------------------------------------------------------------
  For i =0 to size
    currDay = CInt(Left(allDate(i),2))
    year = CInt(Right(allDate(i),4))
    remain = Left(allDate(i),6)
    aMonth = Right(remain,3)

            'Response.write "currday="&currDay&"year="&year&"Month="&aMonth&"Date="&allDate(i) &"         "

    If (year = "1988" OR year = "1992" OR year = "1996" OR year = "2000" OR year = "2004" OR year = "2008" OR year = "2012") Then
       Select Case aMonth
          Case "jan"
             yearDay = currDay
          Case "feb"
             yearDay = 31 + currDay
          Case "mar"
             yearDay = 60 + currDay
          Case "apr"
             yearDay = 91 + currDay
          Case "may"
             yearDay = 121 + currDay
          Case "jun"
             yearDay = 152 + currDay
          Case "jul"
             yearDay = 182 + currDay
          Case "aug"
             yearDay = 213 + currDay
          Case "sep"
             yearDay = 244 + currDay
          Case "oct"
             yearDay = 274 + currDay
          Case "nov"
             yearDay = 305 + currDay
          Case "dec"
             yearDay = 335 + currDay
       End Select
    Else
       Select Case aMonth
	      Case "jan"
	         yearDay = currDay
	      Case "feb"
	         yearDay = 31 + currDay
	      Case "mar"
	         yearDay = 59 + currDay
	      Case "apr"
	         yearDay = 90 + currDay
	      Case "may"
	         yearDay = 120 + currDay
	      Case "jun"
	         yearDay = 151 + currDay
	      Case "jul"
	         yearDay = 181 + currDay
	      Case "aug"
	         yearDay = 212 + currDay
	      Case "sep"
	         yearDay = 243 + currDay
	      Case "oct"
	         yearDay = 273 + currDay
	      Case "nov"
	         yearDay = 304 + currDay
	      Case "dec"
	         yearDay = 334 + currDay
       End Select
    End If

    yrDays(i) = yearDay

  Next
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn GetSceneData(whichProw,mmsceneid,mmydates,mmyyearday,mmyimage,
'                                           mmylocal,recd)
'
' This Sub procedure builds four Pathrow arrays from the SCENE table.
' Each array belongs to a pathrow.
' ==================================================================
Sub GetSceneData(whichProw,mmsceneid,mmydates,mmyyearday,mmyimage,mmylocal,recd)
   Dim senPaRow

   If whichProw = "1" Then
     senPaRow = sFirstProw
   End If

   If whichProw = "2" Then
     senPaRow = sSecondProw
   End If

   If whichProw = "3" Then
     senPaRow = sThirdProw
   End If

   If whichProw = "4" Then
     senPaRow = sFourthProws
   End If

    set objRS  = Server.CreateObject("ADODB.Recordset")
    set objRS.ActiveConnection = objMSSConn

    '** ------------------------------------------------------------
    '** Get the Data records from the Database
    '** ------------------------------------------------------------
    StrQ = " SELECT TO_CHAR(SCENE_ID) AS SCENEID, DATE_ACQUIRED FROM TMMSS_SCENE WHERE PAROW='"&senPaRow&"' "
    StrQ = StrQ & "AND DATE_ACQUIRED BETWEEN '"&sStDate&"' AND '"&sEndDate&"'"
    StrQ = StrQ & "AND CLOUD<='"&sCloud&"' AND SENSOR = 'TM' ORDER BY DATE_ACQUIRED DESC"
    Set objRS = objMSSConn.Execute(StrQ)

    While Not(objRS.EOF)
        mmsceneid(recd) = objRS("SCENEID")
        mmydates(recd) = objRS("DATE_ACQUIRED")

        objRS.MoveNext
        recd = recd + 1
    Wend

    '** ------------------------------------------------------------
    '** The loop added one extra record
    '** ------------------------------------------------------------
    recd = recd - 1

    objRS.close
    Set objRS = Nothing

    '** ------------------------------------------------------------
    '** Calculate Yeardays
    '** ------------------------------------------------------------
    GetYearDay mmydates,recd,mmyyearday

    '** ------------------------------------------------------------
    '** Build the locals and they are local to the center
    '** ------------------------------------------------------------
    For i= 0 to recd
       mmylocal(i)="1"
    Next

    '** ------------------------------------------------------------
    '** Build the URL for Images
    '** ------------------------------------------------------------
    For i =0 to recd
        mmyimage(i) = LSORGserpath & mmsceneid(i) &"//" & "TM"

    Next
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn GetFullMonth(shortMonth,fullMonth,monthNo)
'
' This subroutine completes the a short month name to a full
' name and Month Number.
'
' @param shortName Short Month name.
' @param fullName Full Month Name.
' ==================================================================
Sub GetFullMonth(shortMonth,fullMonth,monthNo)
  Select Case shortMonth
     Case "jan"
       fullMonth = "January"
       monthNo = "01"
     Case "feb"
       fullMonth = "February"
       monthNo = "02"
     Case "mar"
       fullMonth = "March"
       monthNo = "03"
     Case "apr"
       fullMonth = "April"
       monthNo = "04"
     Case "may"
       fullMonth = "May"
       monthNo = "05"
     Case "jun"
       fullMonth = "June"
       monthNo = "06"
     Case "jul"
       fullMonth = "July"
       monthNo = "07"
     Case "aug"
       fullMonth = "August"
       monthNo = "08"
     Case "sep"
       fullMonth = "September"
       monthNo = "09"
     Case "oct"
       fullMonth = "October"
       monthNo = "10"
     Case "nov"
       fullMonth = "November"
       monthNo = "11"
     Case "dec"
       fullMonth = "December"
       monthNo = "12"
     End Select

End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn AddDataArrays

' This Sub procedure combines the two arrays together.
' ==================================================================
Sub AddDataArrays
  Dim i

  If sesizePr1 >= 0 Then
     For i =0 to sesizePr1
        Pr1entityid(sizePr1+i+1) = sPr1sceneId(i)

        Pr1local(sizePr1+i+1) = sPr1local(i)
        Pr1dates(sizePr1+i+1) = sPr1dates(i)
        Pr1yearday(sizePr1+i+1) = sPr1yearday(i)
        Pr1image(sizePr1+i+1) = sPr1image(i)

     Next
     sizePr1 = sizePr1 + sesizePr1 + 1
  End If

  If sesizePr2 >= 0 Then
     For i =0 to sesizePr2
        Pr2entityid(sizePr2+i+1) = sPr2sceneId(i)
        Pr2local(sizePr2+i+1) = sPr2local(i)
        Pr2dates(sizePr2+i+1) = sPr2dates(i)
        Pr2yearday(sizePr2+i+1) = sPr2yearday(i)
        Pr2image(sizePr2+i+1) = sPr2image(i)
     Next
     sizePr2 = sizePr2 + sesizePr2 + 1
  End If

  If sesizePr3 >= 0 Then
     For i =0 to sesizePr3
        Pr3entityid(sizePr3+i+1) = sPr3sceneId(i)
        Pr3local(sizePr3+i+1) = sPr3local(i)
        Pr3dates(sizePr3+i+1) = sPr3dates(i)
        Pr3yearday(sizePr3+i+1) = sPr3yearday(i)
        Pr3image(sizePr3+i+1) = sPr3image(i)
     Next
     sizePr3 = sizePr3 + sesizePr3 + 1
  End If

  If sesizePr4 >= 0 Then
     For i =0 to sesizePr4
        Pr4entityid(sizePr4+i+1) = sPr4sceneId(i)
        Pr4local(sizePr4+i+1) = sPr4local(i)
        Pr4dates(sizePr4+i+1) = sPr4dates(i)
        Pr4yearday(sizePr4+i+1) = sPr4yearday(i)
        Pr4image(sizePr4+i+1) = sPr4image(i)
     Next
     sizePr4 = sizePr4 + sesizePr4 + 1
  End If

End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>
































<%
' ==================================================================
' @fn GetOLIdata(strprow,mmyentityid,mmylocal,mmydates,mmyyearday,
'                                             mmyimage,recd)
'
' This Sub procedure builds four Pathrow arrays. Each array
' belongs to pathrow.
' 


' CHANGE TO Landsat 8 OLI!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


' ==================================================================
Sub GetOLIdata(strprow,mmyentityid,mmylocal,mmydates,mmyyearday,mmyimage,recd)
    set objRS  = Server.CreateObject("ADODB.Recordset")
    set objRS.ActiveConnection = objLsatConn

    '** ------------------------------------------------------------
    '** Get the Data records from the Database
    '** ------------------------------------------------------------
     StrQ = "SELECT ENTITY_ID,STR(YEARDAY) AS YRDAY,BROWSEURL,STR(LOCAL) AS LOCS,CONVERT(VARCHAR(8),acquired,112) AS DATES FROM SCENES_OLI WHERE PAROW = '"&strprow&"'"
     StrQ = StrQ & "AND  ACQUIRED BETWEEN "&iStDate&" AND "&iEndDate&" "
     StrQ = StrQ & "AND CLOUD <='"&icloud&"' ORDER BY acquired "&iSrt&" "
     Set objRS = objLsatConn.Execute(StrQ)

     While Not(objRS.EOF)

       'Response.Write  objRS("DATES") &"   " &objRS("LOCS")  &"   " &objRS("BROWSEURL") & "<BR>" & VbCrLf

        mmyentityid(recd) = objRS("ENTITY_ID")
        mmylocal(recd) = objRS("LOCS")
        mmydates(recd) = objRS("DATES")
        mmyyearday(recd) = objRS("YRDAY")
        mmyimage(recd) = objRS("BROWSEURL")

        objRS.MoveNext
        recd = recd + 1
    Wend

    '** ------------------------------------------------------------
    '** The loop added one extra record
    '** ------------------------------------------------------------
    recd = recd - 1

    objRS.close
    Set objRS = Nothing
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>





<%
' ==================================================================
' @fn GetETMdata(strprow,mmyentityid,mmylocal,mmydates,mmyyearday,
'                                             mmyimage,recd)
'
' This Sub procedure builds four Pathrow arrays. Each array
' belongs to pathrow.
' ==================================================================
Sub GetETMdata(strprow,mmyentityid,mmylocal,mmydates,mmyyearday,mmyimage,recd)
    set objRS  = Server.CreateObject("ADODB.Recordset")
    set objRS.ActiveConnection = objLsatConn

    '** ------------------------------------------------------------
    '** Get the Data records from the Database
    '** ------------------------------------------------------------
     StrQ = "SELECT ENTITY_ID,STR(YEARDAY) AS YRDAY,BROWSEURL,STR(LOCAL) AS LOCS,CONVERT(VARCHAR(8),acquired,112) AS DATES FROM SCENE2 WHERE PAROW = '"&strprow&"'"
     StrQ = StrQ & "AND  ACQUIRED BETWEEN "&iStDate&" AND "&iEndDate&" "
     StrQ = StrQ & "AND CLOUD <='"&icloud&"' ORDER BY acquired "&iSrt&" "
     Set objRS = objLsatConn.Execute(StrQ)

     While Not(objRS.EOF)

       'Response.Write  objRS("DATES") &"   " &objRS("LOCS")  &"   " &objRS("BROWSEURL") & "<BR>" & VbCrLf

        mmyentityid(recd) = objRS("ENTITY_ID")
        mmylocal(recd) = objRS("LOCS")
        mmydates(recd) = objRS("DATES")
        mmyyearday(recd) = objRS("YRDAY")
        mmyimage(recd) = objRS("BROWSEURL")

        objRS.MoveNext
        recd = recd + 1
    Wend

    '** ------------------------------------------------------------
    '** The loop added one extra record
    '** ------------------------------------------------------------
    recd = recd - 1

    objRS.close
    Set objRS = Nothing
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>

<%
' ==================================================================
' @fn sensorError
'
' This procedure shows the error message when there is no sensor
' included in the query.
' ==================================================================
Sub sensorError
%>
	<div style="position:relative; left:150; width:750; color:Blue">
	   <blockquote><p><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
	                  Please include a Sensor: ETM or TM.
	   </blockquote>
    </font></div>

    <FORM>
	   <INPUT TYPE="button" VALUE="Close this window" onClick="self.close()">
	</FORM></center>
<%
End Sub
' ==================================================================
' END SUBROUTINE
' ==================================================================
%>
