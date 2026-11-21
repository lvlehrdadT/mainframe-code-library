/* rexx */ 
HST = 'YOUR_IP_ADDRESS'  
USR ='USERNAME'          
PASS='PASSWORD'  
FILE_name= 'file_name'  
DS = 'dataset_name'   
DSKPFX = 'volser'

GETRC_RC = FTPAPI("FCAI.", "CREATE", "")               
if GETRC_RC <0 then say 'FTP CANNOT CREATE' GETRC_RC   
GETRC_RC = FTPAPI("FCAI.", "INIT", HST )               
if GETRC_RC <0 then say 'INIT FAILED' GETRC_RC         
GETRC_RC = FTPAPI("FCAI.", "SCMD", "USER" USR )        
if GETRC_RC <0 then say 'USER FAILED' GETRC_RC         
GETRC_RC = FTPAPI("FCAI.", "SCMD", "PASS" PASS )       
 if GETRC_RC <0 then say 'PASS FAILED' GETRC_RC        
GETRC_RC = FTPAPI("FCAI.", "SCMD", "LS" )              
 if GETRC_RC <0 then say 'LS FAILED' GETRC_RC          
GETRC_RC = FtpApi('FCAI.', 'GETL_COPY', 'lines.', 'A') 
 if GETRC_RC <0 then say 'INITLV FAILED' GETRC_RC      
do i = 1 to lines.0                                    

 IF INDEX(lines.i,FILE_name)  then do
	CMD = 'QUOTE SIZE' FILE_name                          
	rc = ftpapi("fcai.","SCMD",cmd,"w")              
	if rc < 0 then do                                
		say 'ftp command failed .rc ='rc               
		exit                                           
	end                                              
	
	RC = FtpApi('FCAI.', 'GETL_COPY', 'lines.', 'R') 
	if rc =0 then do                                 
		do I = 1 to lines.0                           
          say lines.I                               
	      parse var lines.i reply size .       
          if reply = '213' then do             
			say 'file size in byte' size      
			size_MB = size / 1024 / 1024      
			say 'file size in Mbyte' size_MB  
		  end  
		end      
	end
   ADDRESS TSO "delete '"DS"'"                       
        ADDRESS TSO 'ALLOC DATASET('"'"DS"'"')',                   
            'VOLUME('DSKPFX||DSKSFX','DSKPFX||DSKSFX+1',           
            'DSKPFX||DSKSFX+2','DSKPFX||DSKSFX+3' ,                
            'DSKPFX||DSKSFX+4','DSKPFX||DSKSFX+5')',               
                'SPACE('65535','65535')',                          
                'SPACE('65535','65535')',                          
                'SPACE('65535','65535')',                          
                'SPACE('65535','65535')',                          
                'SPACE('65535','65535')',                          
                'SPACE('65535','65535')',                          
                'LRECL('925') BLKSIZE('27998') TRACKS',            
                'DSORG('PS') RECFM(V,B)'                           
                                                                     
        DS ="'"DS"'"                                               
        DSKSFX=DSKSFX+6                                            
        QUEUE "FTP "HST                                            
        QUEUE USR" "PASS                                           
        QUEUE "LOCSITE PROGRESS=180"                               
        QUEUE "ASCII"
		ADDRESS TSO    'FREE DA('DS')'        
		QUEUE  " GET "LINES.I" "DS" (replace" 
		QUEUE "QUIT"                          
		QUEUE "    "                          
		QUEUE "  "                            	
 end
end
GETRC_RC = FTPAPI("FCAI.", "TERM")
