setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 5 -file "E:/Users/shan/Dropbox/Projects/V5-ReferenceDesign/v5-counter-test/v5-counter-test/cc123.bit"
Program -p 5 
setMode -bs
deleteDevice -position 5
deleteDevice -position 4
deleteDevice -position 3
deleteDevice -position 2
deleteDevice -position 1
