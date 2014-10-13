#perl throughput
# run by >perl thrput.pl  out1.tr 3 0.0 3.0 > thrput_data

#Get input file
$input = $ARGV[0];
$destnode = $ARGV[1];
$fromport = $ARGV[2];
$toport = $ARGV[3];
$sum = 0;
$clock = 99;

open(DATA, "<$input");
while ( $line = <DATA>)
{
    @x = split(' ', $line);
    if ($x[0] eq 'r')
     {
        if($x[3] eq $destnode && $x[8] eq $fromport &&
          $x[9] eq $toport)
           {
              if ($x[4] eq 'tcp')
               {
                 $sum = $sum + $x[5];
                }
            }
     }
 }

$throughput = .000008 * $sum/$clock;

print "Average Throughput = " , $throughput,"Mbps\n";

close DATA;

exit(0);
       
