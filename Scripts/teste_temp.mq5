//+------------------------------------------------------------------+
//|                                                   teste_temp.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   datetime dtAtualServidor = TimeCurrent();
   Print("Data formatada: ", TimeToString( dtAtualServidor, TIME_MINUTES ) );
   
   }
  
     
//+------------------------------------------------------------------+
