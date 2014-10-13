# Calculating RTT

BEGIN {
   src="0.0";
   dst = "3.0";
   samples = 0;
   total_delay = 0;
}

/^\+/&&$9==src&&$10==dst&&$3=="0"{
  start_time[$11] = $2;
};

/^r/&&$9==dst&&$10==src&&$4=="0"{
 if (start_time[$11] > 0) {
   samples++ ;
   delay = $2 - start_time[$11];
   total_delay += delay;
    };
};
END{
  avg_delay = total_delay/samples;
  print "Average RTT is =" 1000 * avg_delay "ms";
};



   
