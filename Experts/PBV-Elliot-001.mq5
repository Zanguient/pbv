//+------------------------------------------------------------------+
//|                                               PBV-Elliot-001.mq5 |
//|                                                   Gerson Pereira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Gerson Pereira"
#property link      "https://www.mql5.com"
#property version   "1.00"
#resource "\\Indicators\\Examples\\ZigZag.ex5";

#include <Trade\AccountInfo.mqh>
CAccountInfo infoConta;

#include <Trade\SymbolInfo.mqh>
CSymbolInfo ativoInfo;

#include <Trade\Trade.mqh>
CTrade trade;

#include <Trade\OrderInfo.mqh>
COrderInfo ordPend;

double   zzTopoBuffer[];
double   zzFundoBuffer[];
int      zzHandle;
int      totalCopiarBuffer = 100;
double   precoTopoAtual;
double   precoTopoAnterior;
datetime dataTopoAtual;
datetime dataTopoAnterior;

double   precoFundoAtual;
double   precoFundoAnterior;
datetime dataFundoAtual;
datetime dataFundoAnterior;

double difTopo1Fundo1 = 0;
double difTopo2Fundo2 = 0;

datetime tempoCandleBuffer[]; //falta esse vetor no slide

int idRobo = 123456789 ;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   zzHandle = iCustom(_Symbol, _Period, "::Indicators\\Examples\\ZigZag.ex5");
   if(zzHandle == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag: ", GetLastError());
      return(INIT_FAILED);
   }



   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer, true);
   ArraySetAsSeries(zzFundoBuffer, true);

   double   saldo = infoConta.Balance();
   double   lucro = infoConta.Profit();
   double   margemDisp = infoConta.FreeMargin();
   bool     isPermitidoTrade = infoConta.TradeAllowed();
   bool     isPermitidoRobo = infoConta.TradeExpert();    //Slide -> isPermitidoRoto
   // ...
   // Print("Saldo: ", saldo, " ", margemDisp);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   IndicatorRelease(zzHandle);

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---

   /*
      ativoInfo.Name( _Symbol );
      ativoInfo.Refresh();
      double ask = ativoInfo.Ask();
      double bid = ativoInfo.Bid();
      double precoAtual = ativoInfo.Last();
      double volMinOrdem = ativoInfo.LotsMin();
      double tamTick = ativoInfo.TickSize();
      double valorTick = ativoInfo.TickValue();
      // ...
      //Print("ASK: ", ask, " BID: ", " Valor tick: ", valorTick);
   */


   // copia os topos
   if(CopyBuffer(zzHandle, 1, 0, totalCopiarBuffer, zzTopoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos topos: ", GetLastError());
      return;
   }
   int tamVetTopo = ArraySize(zzTopoBuffer);
   int nrTopo = 0;


   // copia os fundos
   if(CopyBuffer(zzHandle, 2, 0, totalCopiarBuffer, zzFundoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos fundos: ", GetLastError());
      return;
   }
   int tamVetFundo = ArraySize(zzFundoBuffer);
   int nrFundo = 0;

   Print("tamVetTop:",tamVetTopo," - ");

   for( int i = 0; i < tamVetTopo; i++ ) {
      if( zzTopoBuffer[i] != 0 ) {
         if( nrTopo == 0 ) {
            //dataTopoAtual = tempoCandleBuffer[i];
            precoTopoAtual = zzTopoBuffer[i];
         } else if( nrTopo == 1 ) {
            //dataTopoAnterior = tempoCandleBuffer[i];
            precoTopoAnterior = zzTopoBuffer[i];
            break;
         }
         nrTopo++;
      }
   } // fim for topo para obter apenas os dois últimos topos mais atuais



   for( int i = 0; i < tamVetFundo; i++ ) {
      if( zzFundoBuffer[i] != 0 ) {
         if( nrFundo == 0 ) {
            //dataFundoAtual = tempoCandleBuffer[i];
            precoFundoAtual = zzFundoBuffer[i];
         } else if( nrFundo == 1 ) {
            //dataFundoAnterior = tempoCandleBuffer[i];
            precoFundoAnterior = zzFundoBuffer[i];
            break;
         }
         nrFundo++;
      }
   } // fim for fundo para obter apenas os dois últimos fundos mais atuais


   //Print("precoFundoAnterior:", precoFundoAnterior, " - precoTopoAnterior:", precoTopoAnterior, " - precoFundoAtual:", precoFundoAtual, " - precoTopoAtual:", precoTopoAtual);

}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void abrirOrdem(ENUM_ORDER_TYPE tipoOrdem, double preco, double volume, double sl = 0, double tp = 0, string coment = "") {

   //+-------------------------------------------------------+
   bool result = true ; // variável não inicializada no slide
   //+-------------------------------------------------------+

   preco = NormalizeDouble(preco, _Digits);
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   trade.SetExpertMagicNumber(idRobo);
   trade.SetTypeFillingBySymbol(_Symbol);


   if(tipoOrdem == ORDER_TYPE_BUY) {
      result = trade.Buy(volume, _Symbol, preco, sl, tp, coment);
   } else if (tipoOrdem == ORDER_TYPE_SELL) {
      result = trade.Sell(volume, _Symbol, preco, sl, tp, coment);
   } else if(tipoOrdem == ORDER_TYPE_BUY_LIMIT) {
      result = trade.BuyLimit(volume, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, coment);
   } else if(tipoOrdem == ORDER_TYPE_SELL_LIMIT) {
      result = trade.SellLimit(volume, preco, _Symbol, sl, tp, ORDER_TIME_GTC, 0, coment);
   }
   if(!result) {
      Print("Erro ao abrir a ordem ", tipoOrdem, ". Código: ", trade.ResultRetcode() );
   }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
void fecharTodasPosicoesRobo() {
   double saldo = 0;
   int totalPosicoes = PositionsTotal();
   for(int i = 0; i < totalPosicoes; i++) {
      string simbolo = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if( simbolo == _Symbol && magic == idRobo ) {
         saldo = PositionGetDouble(POSITION_PROFIT);
         if(!trade.PositionClose(PositionGetTicket(i))) {
            Print("Erro ao fechar a negociação. Código: ", trade.ResultRetcode());
         } else {
            Print("Saldo: ", saldo);
         }
      }
   }
}

*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obterHistoricoNegociacaoRobo() {

   //Funções de Negociação
   HistorySelect(0, TimeCurrent());
   uint total = HistoryDealsTotal();
   ulong ticket = 0;
   double price, profit;
   datetime time;
   string symbol;
   long type, entry;
   for(uint i = 0; i < total; i++) {
      if((ticket = HistoryDealGetTicket(i)) > 0) {
         price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         type = HistoryDealGetInteger(ticket, DEAL_TYPE);
         entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         if( entry == DEAL_ENTRY_OUT ) {
            Print("Ativo: ", symbol, " - Preço saída: ", price, " - Lucro: ", profit);
         }
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fecharTodasOrdensPendentesRobo() {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--) {

      // seleciona a ordem pendente por seu índice
      if( ordPend.SelectByIndex(i) ) {

         // se a ordem pendente for do ativo monitorado e aberta pelo robô
         if(ordPend.Symbol() == _Symbol && ordPend.Magic() == idRobo) {
            if (!trade.OrderDelete(ordPend.Ticket() ) ) {
               Print("Erro ao excluir a ordem pendente ", ordPend.Ticket());
            }
         }
      }
   }
}




//+------------------------------------------------------------------+
