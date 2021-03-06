//+------------------------------------------------------------------+
//|                                           teste_On_Calculate.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate( const int rates_total, const int prev_calculated,
                 const datetime& time[], const double& open[], const double& high[], const double&
                 low[], const double& close[], const long& tick_volume[], const long& volume[],
                 const int& spread[] )
{
   int inicio = 0;
   if( prev_calculated > 0 ) {
      inicio = prev_calculated - 1;
   }
   for(int i= inicio; i < rates_total; i++) {
      Print("Preço abertura: ", open[i] );
      Print("Preço fechamento: ", close[i] );
      Print("Preço máxima: ", high[i] );
      Print("Preço mínima: ", low[i] );
      Print("Volume negociado: ", volume[i] );
   }
// retorna o novo valor para prev_calculated
   return(rates_total);
}
//+------------------------------------------------------------------+
