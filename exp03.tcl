#Create a simulator object
set ns [new Simulator]

#Open the trace file
set f0 [open out0.tr w]
#set f0 [open "| grep \"tcp\" > out1.tr" w] 

set cwndfile [open CWND w]
 
$ns trace-all $f0

#Define a 'finish' procedure
proc finish {} {
        global ns f0
        #Close the trace file
        close $f0
        exit 0
}

#Create six nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Create links between the nodes
$ns duplex-link $n1 $n2 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link $n5 $n2 10Mb 10ms DropTail
$ns duplex-link $n3 $n6 10Mb 10ms DropTail


#Setup a TCP connection
set tcp [new Agent/TCP/Reno]
#cwnd setting_default 12
$tcp set window_ 300
$tcp set wnd_ 300
$tcp set maxcwnd_ 1000
set class_ 2
$ns attach-agent $n1 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 2mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 0.1 "$ftp start"
$ns at 10.0 "$cbr start"
$ns at 100.0 "$cbr stop"
$ns at 100.0 "$ftp stop"

# plotWindow: write CWND from $tcpSource
  proc plotWindow {tcpSource file} {
     global ns
     set time 0.1
     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]
     set wnd [$tcpSource set window_]
     puts $file "$now $cwnd"
     $ns at [expr $now+$time] "plotWindow $tcpSource $file" 
  }

$ns at 0.1 "plotWindow $tcp $cwndfile"

$ns at 100.0 "finish"

#Run the simulation
$ns run

