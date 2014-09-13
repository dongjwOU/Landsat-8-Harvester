#!/usr/bin/python

#-------------------------------------------------------------------#
# Harvest_Landsat8_part2.py
# Created on Jan 13, 2014 by Peter Ferrini (ferrinip21@gmail.com)
# 
# Description:
# Query data in MySQL table to retrieve scenes not in SDE database (rows with status = 0)
# Read and format query results to be inserted into SDE database
#**Run tool to Create Polygon for Scene (removed)
# Update SDE database with new Scenes
# Update field attribute 'status' to '1' in MySQL
#-------------------------------------------------------------------#
# Harvester_Landsat8_part1.py
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
import math
import arcpy
from datetime import date
import MySQLdb
import pyodbc


#Harvest_path = sys.args[0]
#querymonth = sys.args[1]
#if os.path.exists(Harvest_path):
#    continue
#else:
#    sys.exit("Error - parameters - " + str(Harvest_path)+" does not exist")


Harvest_path = r"C:/Users/pferrini/Desktop/Harvester_Updated_v2/"
querymonth = '2013-01-26'

#--- Function Definitions ---#
def getDate():
    today = date.today()
    return today.isoformat()

# Formats image attributes into correct types to match database fields
def getFields(row):
    SceneID = str(row[0])
    ENTITY_ID = SceneID
    WRS2PATH = str(row[1])
    WRS2ROW = str(row[2])
    ACQUIRED = str(row[3])
    YEAR,MONTH,DAY = ACQUIRED.split("-")
    YEARDAY = SceneID[13:16]
    cloud1 = str(row[4])
    if len(cloud1)== 1:
        CLOUD = '00'
    else:
        CLOUD = cloud1[0] + '0'
    QUALITY = str(row[5])
    PAROW = SceneID[3:9]
    BROWSEURL = str(row[6])
    TIR_URL = BROWSEURL[0:-4] + '_TIR' + BROWSEURL[-4:]
    QB_URL = BROWSEURL[0:-4] + '_QB' + BROWSEURL[-4:]
    LOCAL = '0'
    output = "'"+ENTITY_ID+"',"+WRS2PATH+","+WRS2ROW+",'"+ACQUIRED+"',"+YEAR+","+MONTH+","+DAY+","+YEARDAY+","+CLOUD+","+QUALITY+",'"+PAROW+"','"+BROWSEURL+"','"+TIR_URL+"','"+QB_URL+"',"+LOCAL+",0"
    return output



#----------------------------------------------------------------------------------#


print 'running program' + '\n'

#---Define variables---#
MyDB = "mysql"
MyHost = "99.9.999.9"
MyUser = "root"
MyPW = "xxxxxxxx"

#MyDB2 = "EQUATOR"
MyDB2 = "sde"
#MyDB2 = "sde.SCENES_OLI"
MyHost2 = "99.9.999.999"
MyUser2 = "sde"
MyPW2 = "xxxxxxxxxxx"

#Harvest_path = r"C:/Users/pferrini/Desktop/Harvester_Updated_v2/"
#out_path = r"C:/Users/pferrini/Desktop/Harvester_Updated_v2/Data/sde_data/"
scene_path =  Harvest_path + r"Data/sde_data/Scenes/"
field_path =  Harvest_path + r"Data/sde_data/Scenes_fields/"
todaysDate = getDate()
logfile = Harvest_path + r'Data/log/LOG_SCENES_OLI_' + todaysDate + '.txt'

#----------------------------------------------------------------------#

#AcqDate = '2013-11-14'

log = open(logfile,'w')
log.writelines("Updating Equator (SCENES_OLI) database"+"\n"+"\n")

# SQL insert statement format
#INSERT INTO [sde].[sde].[SCENES_OLI] ([ENTITY_ID],[WRS2PATH],[WRS2ROW],[ACQUIRED],[YEAR],[MONTH],[DAY],[YEARDAY],[CLOUD],[QUALITY],[PAROW],[BROWSEURL],[TIR_URL],[QB_URL],[LOCAL],[shape]) VALUES ('LC80980112013101LGN01',98,11,'4/11/2013',2014,4,11,101,0,9,'098011','http://earthexplorer.usgs.gov/browse/landsat_8/2013/098/011/LC80980112013101LGN01.jpg','http://earthexplorer.usgs.gov/browse/landsat_8/2013/098/011/LC80980112013101LGN01_TIR.jpg','http://earthexplorer.usgs.gov/browse/landsat_8/2013/098/011/LC80980112013101LGN01_QB.jpg',0,0);

sql1 = "INSERT INTO sde.SCENES_OLI (ENTITY_ID,WRS2PATH,WRS2ROW,ACQUIRED,YEAR,MONTH,DAY,YEARDAY,CLOUD,QUALITY,PAROW,BROWSEURL,TIR_URL,QB_URL,LOCAL,shape) VALUES "


## Set up database connections and try simple count query to test connection
print "Connecting to Databases..."
try:
    ## Connect to MySQL database
    log.writelines("Connecting to MySQL..."+"\n")
    db = MySQLdb.connect(host=MyHost,user=MyUser,passwd=MyPW,db=MyDB)
    db2 = MySQLdb.connect(host=MyHost,user=MyUser,passwd=MyPW,db=MyDB)
    #
    ## Connect to EQUATOR/sde database
    log.writelines("Connecting to EQUATOR..."+"\n")
    conn_sde = pyodbc.connect('DRIVER={SQL Server};SERVER=35.8.163.156;DATABASE=sde;UID=sde;PWD=sde_equator')
    cursor = conn_sde.cursor()
    row = cursor.execute("select count(*) from sde.SCENES_OLI").fetchone()
    print 'SCENES_OLI Count = '+str(row[0])
    log.writelines('SCENES_OLI Count = '+str(row[0])+'\n')
except MySQLdb.Error as e:
    db.close()
    db2.close()
    conn_sde.close()
    log.close()
    sys.exit("Error connecting to MySQL database")
except pyodbc.Error as e:
    db.close()
    db2.close()
    conn_sde.close()
    log.close()
    sys.exit("Error connecting to EQUATOR database")
cur = db.cursor()
cur2 = db.cursor()


# Get initial count of imagery in database
cur.execute("select count(*) from zharvest.landsat_oli")
for row in cur.fetchall():
    print 'MySQL (zharvest.landsat_oli) Count = '+str(row[0])
    log.writelines('MySQL (zharvest.landsat_oli) Count = '+str(row[0])+'\n')
cur.execute("SELECT count(*) FROM zharvest.landsat_oli WHERE status = '0'")
for row in cur.fetchall():
    print "MySQL count (status=0): "+str(row[0])
    log.writelines("MySQL count (status=0): "+str(row[0])+'\n'+'\n')



### Main Process
try:
    print "Querying MySQL... Inserting fields into EQUATOR..."
    log.writelines("Querying MySQL... Inserting fields into EQUATOR..."+"\n")
    qCount = 0
    xCount = 0
    uCount = 0
    num_scenes = 0
    #sql_cnt = "select count(*) from zharvest.landsat_oli where entityid != '" + SceneID + "' and acqdate < '2014-02-01'and acqdate >= '2014-01-01'"
    sql_cnt = "SELECT count(*) FROM zharvest.landsat_oli WHERE status = '0' AND acqdate >= '"+querymonth+"'"
    log.writelines('Executing Query: "'+sql_cnt+'"...'+"\n")
    cur.execute(sql_cnt)
    for count_scenes in cur.fetchall():
        print "Number of Scenes to be inserted = "+str(count_scenes[0])
        num_scenes = int(count_scenes[0])
        log.writelines("Number of Scenes to be inserted into SCENES_OLI: "+str(num_scenes)+'\n'+'\n')
    ###
    ### Query the MySQL database, Insert rows into EQUATOR database
    log.writelines("Processing Scenes..."+'\n')
    print "Processing..."
    sql_str = "SELECT entityid,path,row,acqdate,cloud,quality,browseurl FROM zharvest.landsat_oli WHERE status = '0' AND acqdate >= '"+querymonth+"'"
    cur.execute(sql_str)
    for row in cur.fetchall():
        Sceneid = str(row[0])
        sql_2 = "select count(*) from sde.SCENES_OLI where ENTITY_ID = '"+Sceneid+"'"
        num = cursor.execute(sql_2).fetchone()
        

        #### Insert Scene #################################
        if str(num[0]) == '0': #Check to see if Scene is already in table sde.SCENES_OLI            
            values = getFields(row)
            sql_dump = sql1 + "(" + values + ")"
            cursor.execute(sql_dump)
            cursor.commit()
            
            ## Update status
            try:
                sql_status_update = "UPDATE zharvest.landsat_oli SET status = '1' WHERE entityid = '"+str(Sceneid)+"'"
                cur2.execute(sql_status_update)
                uCount += 1
            except MySQLdb.Error:
                log.writelines("Failed to update MySQL status for"+'\n'+str(Sceneid)+'\n')
                print "Status Update (MySQL) Failed!"
            qCount += 1

        #### Skip Scene #################################
        else:
            log.writelines(Sceneid+" already in SDE database.. Skipping it")
            xCount += 1


    log.writelines("Number of Scenes inserted into SCENES_OLI: "+str(qCount)+'\n')
    log.writelines("Number of Scenes skipped: "+str(xCount)+'\n'+'\n')
except MySQLdb.Error as e:
    print '\n'+"MySQL Error: "+str(e)+'\n'+"query count: "+str(qCount)+', update count: '+str(uCount)+', duplicates: '+str(xCount)
    log.writelines('\n'+"MySQL Error: "+str(e)+'\n'+"query count: "+str(qCount)+', update count: '+str(uCount)+', duplicates: '+str(xCount)+'\n')
    log.writelines("Did not insert all scenes into SCENES_OLI...")
    log.close()
    cur.close()
    db.close()
    cur2.close()
    db2.close()
    cursor.close()
    conn_sde.close()
    sys.exit("Error connecting to MySQL database")
except pyodbc.Error as e:
    print '\n'+"pyodbc Error: "+str(e)+'\n'+"query count: "+str(qCount)+', update count: '+str(uCount)+', duplicates: '+str(xCount)
    log.writelines('\n'+"pyodbc Error: "+str(e)+'\n'+"query count: "+str(qCount)+', update count: '+str(uCount)+', duplicates: '+str(xCount)+'\n')
    log.writelines("Did not insert all scenes into SCENES_OLI...")
    log.close()
    cur.close()
    db.close()
    cur2.close()
    db2.close()
    cursor.close()
    conn_sde.close()
    sys.exit("Error connecting to EQUATOR database")

## Close database connection
cur2.close()
db2.close()

print '\n'+"EQUATOR (sde.SCENES_OLI) successfully updated"
print "Query INSERTs count = "+str(qCount)+', duplicates: '+str(xCount) + '\n'
log.writelines('\n'+"Updated Equator database (SCENES_OLI) successfully"+"\n"+"\n")
log.writelines("Query count: "+str(qCount)+', update count: '+str(uCount)+', duplicates: '+str(xCount)+'\n')

## New count of imagery in database
cur.execute("SELECT count(*) FROM zharvest.landsat_oli WHERE status = '0'")
for row in cur.fetchall():
    print "MySQL count (status=0): ",str(row[0])
    log.writelines("MySQL count (status=0): "+str(row[0])+'\n')
cur.execute("select count(*) from zharvest.landsat_oli")
for row in cur.fetchall():
    print 'MySQL (zharvest.landsat_oli) Count = '+str(row[0])
    log.writelines('MySQL (zharvest.landsat_oli) Count = '+str(row[0])+'\n')
row = cursor.execute("select count(*) from sde.SCENES_OLI").fetchone()
print 'SDE (SCENES_OLI) Count = '+str(row[0])
log.writelines('SDE (SCENES_OLI) Count = '+str(row[0])+'\n'+'\n')


log.writelines("\n"+"Program finished running successfully"+'\n')

## Close nessasary parameters
log.close()
cur.close()
db.close()
cursor.close()
conn_sde.close()

print '\n','Program Finished'



##------------------------------------------------------------------------------------------------------##

# Download link to daily updated Landsat8 OLI metadata
# http://landsat.usgs.gov/metadata_service/bulk_metadata_files/LANDSAT_8.csv

# New Browser URL: http://earthexplorer.usgs.gov/browse/landsat_8/year/ppp/rrr/SceneID.jpg

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



