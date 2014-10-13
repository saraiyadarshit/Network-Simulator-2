#perl drop_rate_new.pl out0.tr 0 1

$input = $ARGV[0];
$fromnode = $ARGV[1];
$tonode = $ARGV[2];
$fid = 1;

$packet_drop = 0;
$packet_sent = 0;
$drop_rate = 0;

open(DATA, "<$input");
while ($line = <DATA>)
{
    @x = split(' ', $line);
    if ($x[0] eq '+' && $x[7] eq $fid && $x[4] eq 'tcp')
         {
            $packet_sent = $packet_sent + 1;
         }
    if ($x[0] eq 'd' && $x[7] eq $fid)
         {
            $packet_drop = $packet_drop + 1;
         }
}
print "Packet sent from node 0=", $packet_sent;
print "Packet drop ", $packet_drop;
if ($packet_sent !=0)
{
  $drop_rate = 100 * $packet_drop/$packet_sent;

}

print "Drop rate of TCP Flow =" , $drop_rate;
close DATA;
exit(0); 




