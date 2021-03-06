#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

struct precos {
   double abertura , fechamento , maxima , minima ;
};


double media(precos &candle)
{
   return (candle.abertura + candle.fechamento + candle.maxima + candle.minima) / 4;
}

void OnStart() {
//---
   precos ultimos_candles[3];
   
   ultimos_candles[0].abertura = 10.0;
   ultimos_candles[0].fechamento =  10.5;
   ultimos_candles[0].maxima = 11.0 ;
   ultimos_candles[0].minima = 9.8 ;
   
   ultimos_candles[1].abertura = 10.5;
   ultimos_candles[1].fechamento =  10.9;
   ultimos_candles[1].maxima = 11.4 ;
   ultimos_candles[1].minima = 10.1 ;
      
   ultimos_candles[2].abertura = 10.9;
   ultimos_candles[2].fechamento =  11.4;
   ultimos_candles[2].maxima = 11.2 ;
   ultimos_candles[2].minima = 10.6 ;

   double media_3_periodos = 0 ;
   
   for(int i=0;i<3;i++)
     {
         media_3_periodos += media(ultimos_candles[i]);
         Print("Media Atual : ", media_3_periodos);
     }

   media_3_periodos /= 3;
   Print("Media 3 Períodos : ", media_3_periodos);

}
//+------------------------------------------------------------------+
