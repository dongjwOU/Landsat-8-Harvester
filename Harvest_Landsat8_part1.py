#!/usr/bin/python

#-------------------------------------------------------------------#
# Harvest_Landsat8_part1.py
# Created on Oct 10, 2013 by Peter Ferrini (ferrinip21@gmail.com)
#
# Description:
# Retrieve Landsat8 Metadata from the USGS-EROS Archive
#  - save table in .csv format to disk space
# Read and format metadata from rows in .csv file (Landsat 8 Scenes)
# Update MySQL database with new Scene metadata
#  - insert data from .csv table into MySQL table
#  - set 'status' field to '0' to show newly added scene
#-------------------------------------------------------------------#
# Harvester_Landsat8_part2.py
# Created on Jan 13, 2014 by Peter Ferrini (ferrinip21@gmail.com)
# 
# Description:
# Query data in MySQL table to retrieve scenes not in SDE database (rows with status = 0)
# Read and format query results to be inserted into SDE database
#**Run tool to Create Polygon for Scene (removed)
# Update SDE database with new Scenes
# Update field attribute 'status' to '1' in MySQL
#-------------------------------------------------------------------#
#
# Purpose:
#
# Harvests new Landsat 8 imagery from USGS website. Formats the attributes
# and stores metadata in geodatabase. Running program daily keeps the
# database updated with ALL imagery from Landsat 8.
#
#-------------------------------------------------------------------#

#---Import system modules---#
##import shutil
import os
import sys
##import subprocess
import random
import math
import time
import arcpy
import urllib
import urllib2
from datetime import date
import csv
import MySQLdb



#--- Function Definitions ---#
def getDate():
    today = date.today()
    return today.isoformat()


# Downloads table from url in .csv format and saves to outPath
def downloadMetadata(url,outPath):
    #url = r"http://landsat.usgs.gov/metadata_service/bulk_metadata_files/LANDSAT_8.csv"
    try:
        f = urllib2.urlopen(url)
        print "downloading " + url
        with open(outPath,'wb') as code:
            code.write(f.read())
        f.close()
    #handle errors
    except urllib2.HTTPError, e:
        print "HTTP Error:", e.code, url
        sys.exit("Error occured while retrieving Landsat8 metadata")
    except urllib2.URLError, e:
        print "URL Error:", e.reason, url
        sys.exit("Error occured while retrieving Landsat8 metadata")


# Takes correct attributes from row from .csv table
def Row2Field_SDE(row):
    OBJECTID = 1
    ENTITY_ID = row[0]
    WRS2PATH = row[6]
    WRS2ROW = row[7]
    ACQUIRED = row[2].zfill(10)
    YEAR = ACQUIRED[0:4]
    MONTH = ACQUIRED[5:7]
    DAY = ACQUIRED[8:]
    YEARDAY = ENTITY_ID[13:16]
    CLOUD = row[18]
    PAROW = row[6].zfill(3) + row[7].zfill(3)
    BROWSEURL = row[5]
    LOCAL = 0
    '''
    EXPOSED
    SDE
    SCENE_ID
    SAT_PATH
    SAT_ROW
    SENSOR
    DATE_ACQUI
    YEAR_ACQUI
    MONTH_ACQU
    CLOUD_COVE
    PATH
    FILENAME
    shape.area
    shape.len
    '''
    Scene_row = [OBJECTID,ENTITY_ID,WRS2PATH,WRS2ROW,ACQUIRED,YEAR,MONTH,DAY,YEARDAY,CLOUD,PAROW,BROWSEURL,LOCAL]
    return Scene_row
    

# Formats image metadata into the correct type of database fields
def Row2Scene_SQL(rowList):
    try:
        Sid = rowList[0]
        uniqid = Sid[0:16]
        entityid = Sid
        #status = 0
        acqdate = str(rowList[2])
        pubdate = str(rowList[3])
        begdate = getDate() ##begdate is date scene updated to mysql database (or is that pubdate?)
        row = str(int(rowList[7]))
        path = str(int(rowList[6]))
        cloud = str(rowList[18]) + '0'
        gsi = rowList[28]
        version = Sid[-2:]
        ullat = rowList[8]
        ullong = rowList[9]
        urlat = rowList[10]
        urlong = rowList[11]
        lrlat = rowList[14]
        lrlong = rowList[15]
        lllat = rowList[12]
        lllong = rowList[13]
        browseurl = rowList[5]
        subdir = '8/'+ begdate[0:4] + '/' + begdate[5:7] + begdate[8:]
        avail = rowList[4]
        #footprint = geometry. polygon built from lat/long coords using arcpy
        quality = rowList[32]
        sunElevation = rowList[26]
        sunAzimuth = rowList[27]
        
        Scene_row = [uniqid,entityid,acqdate,pubdate,begdate,row,path,cloud,gsi,version,ullat,ullong,urlat,urlong,lrlat,lrlong,lllat,lllong,browseurl,subdir,avail,quality,sunElevation,sunAzimuth]
        return Scene_row
    except ValueError, e:
        print "Value Error: " + str(e)
        db.close()
        cur.close()
        log.close()
        sys.exit("Unable to get values from csv file")
    
######### primary function ###############
# Inserts scenes from .csv table rows into MySQL database
def csv_2_MySQL(metafile,cur,log):
    with open(metafile, 'rb') as f:
        reader = csv.reader(f)
        count = 0
        DupCount = 0 #num of duplicate scenes (already in database)
        KeepGoing = True
        try:
            for row in reader:
                if row[0] == 'sceneID':
                    continue
                available = str(row[4])
                if available == 'N' or available == 'n':
                    log.writelines('Skipping scene '+ str(row[0])+" - Available = 'N'"+'\n'+'Count: '+str(count)+'\n')
                    print 'Skipping scene '+ str(row[0])+" - Available = 'N'"+'\n'+'Count: '+str(count)
                    continue
                #LC8ppprrryyyydddLGN00
                count += 1
                scene = Row2Scene_SQL(row)
                mySceneID = scene[1]
                SQL = "INSERT INTO zharvest.landsat_oli (uniqid,entityid,acqdate,pubdate,begdate,row,path,cloud,gsi,version,ullat,ullong,urlat,urlong,lrlat,lrlong,lllat,lllong,browseurl,subdir,avail,quality,sunElevation,sunAzimuth) VALUES "
                for f in scene:
                    if f == scene[0]:
                        Values = "'" + f + "'"
                    else:
                        Values = Values + ",'" + f + "'"
                SQL_dump = SQL + '(' + Values + ')'

                ans = count % 100
                if ans == 0:
                    log.writelines('Scenes processed: '+str(count)+', Current sceneID: '+scene[1]+'\n')
                    
                #Update Database if new scene
                try:
                    #uniqid,entityid,acqdate,pubdate,begdate,row,path,cloud,gsi,version,ullat,ullong,urlat,urlong,lrlat,lrlong,lllat,lllong,browseurl,subdir,avail,quality,SunElevation,sunAzimuth (0-23)
                    cur.execute(SQL_dump)
                except MySQLdb.Error, message:
                    errorcode = message[0]
                    if errorcode == 1062:
                        count = count - 1
                        DupCount += 1
                        log.writelines('Scenes inserted: '+str(count)+', Duplicate Count: '+str(DupCount)+', ')
                        log.writelines('Duplicate Error: '+ str(message) + '\n')
                        if KeepGoing:
                            if DupCount > 1000: #breaks loop after 1000 duplicates
                                KeepGoing = False
                            continue
                        log.writelines("MySQL update complete!" + '\n' + '\n')
                        return True
                    else:
                        print "Failed to update scene",scene[1], ", Error: ",str(message)
                        log.writelines("Failed to update current scene " + scene[1] +  ", ErrorCode: " + str(message) + ", Count = " + str(count-1) + '\n')
                        return False
        except csv.Error, e:
            log.writelines("Failed to update scenes, Count = " + str(count))
            log.writelines('file %s, line %d: %s' % (meta_file, reader.line_num, e))
            print 'file %s, line %d: %s' % (meta_file, reader.line_num, e)
            return False
    log.writelines("Last Scene Inserted: " + scene[1] +  ", Number of Scenes Inserted: " + str(count) + '\n')
    log.writelines("MySQL update complete" + '\n' + '\n')
    print 'count:',str(count)
    return True



#---------------------------------------------------------------------------------#


print 'running program' + '\n'

#---Define variables---#
MyDB = "mysql"
MyHost = "99.9.999.9"
MyUser = "root"
MyPW = "xxxxxxxx"

path1 = r"C:/Users/pferrini/Desktop/Harvester_Updated_v2/Data/log/"
out_path = r"C:/Users/pferrini/Desktop/Harvester_Updated_v2/Data/mysql_data/"
todaysDate = getDate()
metaFile = out_path + "LANDSAT_8_" + todaysDate + ".csv"
metaURL = r"http://landsat.usgs.gov/metadata_service/bulk_metadata_files/LANDSAT_8.csv"
logfile = path1 + 'LOG_MySQL_landsat_oli_' + todaysDate + '.txt'




#-----Main Process-----#

### Download metadata
log = open(logfile,'w')
log.writelines('Log file for NewHarvester_Landsat8_MySQL.py'+'\n')
log.writelines(' - Downloads and Reads Landsat metadata from USGS Archive'+'\n')
log.writelines(' - Updates MySQL (Old Greenwhich) database with new scenes'+'\n'+'\n')
log.writelines('Metadata URL: '+ metaURL+'\n')
log.writelines('Metadata Path: '+ metaFile+'\n')
log.writelines('Downloading.... '+'\n')
downloadMetadata(metaURL,metaFile)
log.writelines('\n')


### Connect to MySQL database
log.writelines('Connecting to MySQL Database...' +  '\n')
try:
    db = MySQLdb.connect(host=MyHost,user=MyUser,passwd=MyPW,db=MyDB)
except MySQLdb.Error as e:
    print "MySQL Error:", str(e)
    log.writelines("Error connecting to MySQL database" +  '\n')
    log.close()
    sys.exit("Error connecting to MySQL database")
cur = db.cursor()

# Original count for database
try:
    cur.execute("select count(*) from zharvest.landsat_oli")
    for row in cur.fetchall():
        print str(row[0])
        log.writelines("Current count of landsat_oli Scenes :" + str(row[0]) +  '\n')
except MySQLdb.Error, e:
    print "Failed to execute query and print rows"
    print "Error code:",str(e)
    cur.close()
    db.close()
    log.close()
    sys.exit("Error on count query. Error = " + str(e))
log.writelines('\n')


### Update MySQL database from metadata(.csv) file
log.writelines('Updating MySQL database "landsat_oli"...' +  '\n')
worked = False
worked = csv_2_MySQL(metaFile,cur,log)
if worked == False:
    cur.close()
    db.close()
    log.close()
    sys.exit("Error updating the MySQL database")

#From: harvester/cov2sdeVersion10.py
# Process: Append
#arcpy.Append_management
#arcpy.Append_management("C:\\harvester\\c1\\polygon", sde_SDE_SCENE2, "NO_TEST", "......below.......", "")


### Final count of MySQL and closing connections
try:
    cur.execute("select count(*) from zharvest.landsat_oli")
    for row in cur.fetchall():
        print str(row[0])
        log.writelines("New count of landsat_oli Scenes :" + str(row[0]) +  '\n')
except MySQLdb.Error, e:
    print "Failed to execute query and print rows"
    print "Error = ", str(e)
cur.close()
db.close()
log.close()

print '\n','Program Finished'


##------------------------------------------------------------------------------------------------------##

# Download link to daily updated Landsat8 OLI metadata
# http://landsat.usgs.gov/metadata_service/bulk_metadata_files/LANDSAT_8.csv


#LC8ppprrr2013dddLGNvv


## New Browser URL: http://earthexplorer.usgs.gov/browse/landsat_8/year/ppp/rrr/SceneID.jpg
##  Natural Color = .jpg, Thermal = _TIR.jpg, Quality= _QB.jpg
#Ground Stations??? - LGN, NSG, EDC, ASN, PFS, 
#Versions?? - 00, 01, 02

'''
Ground Stations:

    AAA = Data held by EROS, North American receiving site unknown
    ASA = Data held by EROS, Receiving station, Alice Springs, Australia
    ASN = Data held by EROS, Receiving station, Alice Springs, Australia
    BJC = Data held by EROS, Receiving station, Beijing, China
    BKT = Data held by EROS, Receiving station, Bangkok, Thailand
    CHM = Data held by EROS, Receiving station, Chetumal, Mexico
    COA = Data held by EROS, Receiving station, Cordoba, Argentina
    CPE = Data held by EROS, Receiving station, Cotopaxi, Ecuador
    CUB = Data held by EROS, Receiving station, Cuiaba, Brazil
    DKI = Data held by EROS, Receiving station, Parepare, Indonesia
    EDC = Data held by EROS, Receiving station unknown
    FUI = Data held by EROS, Receiving station, Fucino, Italy (Historical)
    GLC = Data held by EROS, Receiving station, Gilmore Creek, AK, US
    GNC = Data held by EROS, Receiving station, Gatineau, Canada
    HAJ = Data held by EROS, Receiving station, Hatoyama, Japan
    HIJ = Data held by EROS, Receiving station, Hiroshima, Japan
    HOA = Data held by EROS, Receiving station, Hobart, Australia
    IKR = Data held by EROS, Receiving station, Irkutsk, Russia
    ISP = Data held by EROS, Receiving station, Islamabad, Pakistan
    JSA = Data held by EROS, Receiving station, Hartebeesthoek, South Africa
    KIS = Data held by EROS, Receiving station, Kiruna, Sweden 
    KHC = Data held by EROS, Receiving station, KaShi, China
******MOST COMMON FOR Landsat8********************************************************	
    LGS = Data held by EROS, Landsat 5 data acquired by EROS (beginning July 1, 2001)
******MOST COMMON FOR Landsat8********************************************************
    MGR = Data held by EROS, Receiving station, Magadan, Russia
    MLK = Data held by EROS, Receiving station, Malinda, Kenya
    MOR = Data held by EROS, Receiving station, Moscow, Russia
    MPS = Data held by EROS, Receiving station, Maspalomas, Spain
    MTI = Data held by EROS, Receiving station, Matera, Italy
    NSG = Data held by EROS, Receiving station, Neustrelitz, Germany
    PAC = Data held by EROS, Receiving station, Prince Albert, Canada
    PFS = Data held by EROS, Receiving station, Poker Flats, Alaska
    SGS = Data held by EROS, Receiving station, Svalbard, Norway
    SGI = Data held by EROS, Receiving station, Shandnagar, India
    XXO = Data held by EROS, Receiving station unknown
    XXX = Data held by EROS, Receiving station unknown



sde.SCENE2 Fields:
OBJECTID \"OBJECTID\" true true false 4 Long 0 10 ,First,#;
ENTITY_ID \"ENTITY_ID\" true true false 21 Text 0 0 ,First,#;
WRS2PATH \"WRS2PATH\" true true false 4 Long 0 10 ,First,#;
WRS2ROW \"WRS2ROW\" true true false 4 Long 0 10 ,First,#;
ACQUIRED \"ACQUIRED\" true true false 36 Date 0 0 ,First,#;
YEAR \"YEAR\" true true false 4 Long 0 10 ,First,#;
MONTH \"MONTH\" true true false 4 Long 0 10 ,First,#;
DAY \"DAY\" true true false 4 Long 0 10 ,First,#;
YEARDAY \"YEARDAY\" true true false 4 Long 0 10 ,First,#;
CLOUD \"CLOUD\" true true false 4 Long 0 10 ,First,#;
PAROW \"PAROW\" true true false 6 Text 0 0 ,First,#;
BROWSEURL \"BROWSEURL\" true true false 120 Text 0 0 ,First,#;
LOCAL \"LOCAL\" true true false 8 Double 10 29 ,First,#;
EXPOSED \"EXPOSED\" true true false 8 Double 10 29 ,First,#;
SDE \"SDE\" true true false 8 Double 10 29 ,First,#;
SCENE_ID \"SCENE_ID\" true true false 8 Double 9 28 ,First,#;
SAT_PATH \"SAT_PATH\" true true false 8 Double 9 28 ,First,#;
SAT_ROW \"SAT_ROW\" true true false 8 Double 9 28 ,First,#;
SENSOR \"SENSOR\" true true false 4 Text 0 0 ,First,#;
DATE_ACQUI \"DATE_ACQUI\" true true false 14 Text 0 0 ,First,#;
YEAR_ACQUI \"YEAR_ACQUI\" true true false 8 Double 9 28 ,First,#;
MONTH_ACQU \"MONTH_ACQU\" true true false 8 Double 9 28 ,First,#;
CLOUD_COVE \"CLOUD_COVE\" true true false 8 Double 9 28 ,First,#;
PATH \"PATH\" true true false 70 Text 0 0 ,First,#;
FILENAME \"FILENAME\" true true false 25 Text 0 0 ,First,#;
shape.area \"shape.area\" false false true 0 Double 0 0 ,First,#;
shape.len \"shape.len\" false false true 0 Double 0 0 ,First,#

sde.SCENE2 Field Formats:
1,"LE72240812012189EDC00",224,81,2012-07-07,2012,07,07,189,10,224081,http://earthexplorer.usgs.gov/browse/etm/224/81/2012/LE72240812012189EDC00.jpg,0
-ObjectID, EntityID, WRS2PATH, WRS2ROW, Acquired, Year, Month, Day, YearDay, Cloud, PaRow, BrowseURL, Local???
-------------------------------------------------------------------------------------------------------------
MySQL - Table:landsat_etm - Fields:
uniqid
entityid
status
acqdate
pubdate
begdate 
row
path
cloud
gsi - ground station, ex. 'LGN'
version
ullat
ullong
urlat
urlong
lrlat
lrlong
lllat
lllong
browseurl
subdir - ex. '7/2008/0604' (7 -> Landsat7, year, MonthDay)
avail - ex. 'Y'
footprint - ???????

'''

#More Websites:
# EarthExplorer Metadata: http://earthexplorer.usgs.gov/metadata/4923/LC81780332013101LGN01/
# GloVis Metadata: http://glovis.usgs.gov/ImgViewer/showmetadata.cgi?scene_id=LC80280302013298LGN00
# ESA landsat8 web portal (only Europes images) - landsat8.portal.eo.esa.int/portal/
#https://landsat8portal.eo.esa.int/servlets/thumbnail?ID=LC81970352013282NSG00&NODE=LDCM-int
#https://landsat8portal.eo.esa.int/servlets/quicklook?ID=LC81970352013282NSG00&NODE=LDCM-int&MAXSIZE=300
#http://edcsns17.cr.usgs.gov/browse/etm/68/95/2011/LE70680952011245EDC00.jpg   (harvester files - etm)

## New Browser URL: http://earthexplorer.usgs.gov/browse/landsat_8/year/ppp/rrr/SceneID + .jpg or _TIR.jpg or _QB.jpg
#website = "http://earthexplorer.usgs.gov/browse/landsat_8/"
#website = http://edcsns17.cr.usgs.gov/browse/etm/225/81/2011/LE72250812011305EDC00.jpg  #from Harvester file c25.txt
#website = "https://landsat8portal.eo.esa.int/portal/"



