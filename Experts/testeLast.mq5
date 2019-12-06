//+------------------------------------------------------------------+
//|                                                    testeLast.mq5 |
//|                                                   Gerson Pereira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Gerson Pereira"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade\AccountInfo.mqh>
CAccountInfo infoConta;

long precoAtual = 0;

#include <Trade\SymbolInfo.mqh>
CSymbolInfo ativoInfo;


#include <Trade\Trade.mqh>
CTrade trade;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double precoAtual = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   
   Print("precoAtual:",precoAtual);
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
