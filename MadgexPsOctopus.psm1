$publicFunctions  = Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
$privateFunctions = Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue
$publicFunctions | %{
	$functionName = $_.Name
	try{
		. $_.FullName
	}catch{
		throw "Error importing $functionName - $($_.exception.message)"
	}
}
$privateFunctions | %{
	try{
		. $_.FullName
	}catch{
		throw "Error importing $functionName - $($_.exception.message)"
	}
}
#                                      TobyTobyT                                         
#                                  obyTobyTobyTobyTo                                     
#                              byTobyTobyTobyTobyTobyTo                                  
#                      byTobyTobyTobyT           obyTobyT                                
#                   obyTobyTobyTo                  byTobyT                               
#                 obyTobyTobyToby                   TobyTo                               
#                 byTobyTobyTobyTo                   byTob                               
#                 yTobyTobyTo byToby    TobyTobyTob  yToby                               
#                 TobyTobyTobyTobyTob yTobyTobyTobyTo byTo                               
#                 byTobyTobyTobyTob  yTobyTobyTobyTobyToby                               
#                TobyT  obyTobyToby  TobyTobyTobyTobyTobyT                               
#               obyTobyTobyTobyTobyT obyTobyToby TobyTobyT                               
#              obyTobyTobyTobyToby   TobyTobyTobyTobyTobyT                               
#             obyTobyTobyTobyTobyTobyTobyTobyTobyT  obyTo                                
#            byTob          yTobyTobyTobyTobyT     obyTob                                
#           yToby                      TobyTob     yTobyT                                
#          obyTob                                 yTobyT                                 
#         obyTob                                 yTobyT                                  
#        obyTob                                  yTobyT                                  
#        obyTo                      byTo        byToby                                   
#        Toby                      TobyT oby   TobyTo                                    
#        byTo                      byTobyToby  TobyT                         obyTobyTo   
#       byTob                      yTobyToby  TobyT                        obyTobyTobyT  
#       obyTo                     byTobyToby TobyT                       obyTob    yTob  
#       yToby                     TobyTobyT  obyTo                     byTobyT    obyTo  
#       byTob                    yTobyToby  TobyTo                   byTobyT     obyTo   
#       byTob                    yTobyTob   yTobyTobyTobyTobyTob   yTobyTo     byTob     
#        yTob                   yTobyTob    yTobyTobyTobyTobyTobyTobyTob      yToby      
#        Toby                   TobyTob     yToby   TobyT   obyTobyTob      yTobyT       
#        obyT                  obyTobyT      oby   TobyTobyTobyTobyT      obyTob         
#        yToby               TobyT obyTo         byTobyTobyTobyToby     TobyTob          
#         yTob             yToby  TobyTob         yTobyTobyTobyTobyTo   byTobyTo         
#         byTob            yTobyTobyTobyT                     obyTobyT    obyTobyTo      
#          byTob            yTobyTobyTob              yTob       yTobyT  obyT obyTo      
#          byToby              Toby                   Toby        TobyTo  byTobyTo       
#           byToby                                Tob              yToby    Toby         
#            TobyToby                            Toby              TobyT     obyT        
#               obyToby                          Toby              TobyTobyTobyTo        
#     byT        obyTobyTob                       yTob           yTobyTobyTobyTo         
#    byTobyT    obyTobyTobyTobyTo                  byT         obyToby    T              
#    obyTobyTobyTob yTobyTobyTobyTobyToby           Toby    TobyTob                      
#    yTob yTobyTobyTobyT    obyTobyTobyToby TobyTobyTobyTobyTobyT                        
#     obyT  obyTobyTob         yTobyTobyTo byTobyTobyTobyTobyT                           
#      obyT   obyTob         yTobyTobyTob yToby TobyTobyTob                              
#       yTobyTobyT           obyTobyToby  Toby                                           
#        TobyTob              yTobyTob   yTob                                            
#          yTo                byToby    Toby                                             
#                              TobyTo  byTo                                              
#                               byTobyToby                                               
#                                 TobyTob                                                
#                                   yTo

