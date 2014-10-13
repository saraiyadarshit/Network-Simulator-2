#Create a simulator object
set ns [new Simulator]

#Open the trace file
set f0 [open out0.tr w]
#set f0 [open "| grep \"tcp\" > out1.tr" w]
#set f0 [open " grep \"^r\" \"tcp\"> out0.tr" w]  

# -------------------------------
# Open the Window plot file
# -------------------------------
  set winfile [open WinFile_nr_v w]
  set winfile2 [open WinFile2_nr_v w]
 
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

#Set Queue Size of link (n2-n3) to 10
#$ns queue-limit $n2 $n3 10

#Setup a TCP connection 1 from N1 -> N4
set tcp0 [new Agent/TCP/Newreno]
#cwnd setting_default 12
$tcp0 set window_ 300
$tcp0 set wnd_ 300
$tcp0 set maxcwnd_ 1000
set class_ 2
$ns attach-agent $n1 $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0
$ns connect $tcp0 $sink0
$tcp0 set fid_ 1

#Setup a FTP over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP

#Setup a TCP connection 2 from N5 -> N6
set tcp1 [new Agent/TCP/Vegas]
#cwnd setting_default 12
$tcp1 set window_ 300
$tcp1 set wnd_ 300
$tcp1 set maxcwnd_ 1000
set class_ 2
$ns attach-agent $n5 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n6 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 2

#Setup a FTP over TCP connection 2
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP


#Setup a UDP connection from N2 -> N3
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 3

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 2mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp0 start"
$ns at 1.0 "$ftp1 start"
$ns at 100.0 "$ftp1 stop"
$ns at 100.0 "$ftp0 stop"
$ns at 100.5 "$cbr stop"

#Detach tcp and sink agents (not really necessary)
#$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

# -----------------------------------------------------------------
# plotWindow(tcpSource,file): write CWND from $tcpSource
#			      to output file $file every 0.1 sec
# -----------------------------------------------------------------
  proc plotWindow {tcpSource file} {
     global ns
     set time 0.1
     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]
     set wnd [$tcpSource set window_]
     puts $file "$now $cwnd"
     $ns at [expr $now+$time] "plotWindow $tcpSource $file" 
  }

# -----------------------------------------------------------
# Start plotWindow for TCP 0 and TCP 1
# -----------------------------------------------------------
$ns at 1.0 "plotWindow $tcp0 $winfile"
$ns at 1.0 "plotWindow $tcp1 $winfile2"

#Call the finish procedure after simulation time
$ns at 100.5 "finish"

#Run the simulation
$ns run

