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

#include <ChartObjects\ChartObjectsArrows.mqh>
CChartObjectArrow icone;

long     volumeBuffer[]; // Foi necessário alterar de double para long, conforme documentação
double   zzTopoBuffer[];
double   zzFundoBuffer[];
datetime zzDataFundo[];
datetime zzDataTopo[];
int      totalCopiarBuffer = 50;
int      zzHandle;

double   precoTopoAtual;
double   precoTopoAnterior;
datetime dataTopoAtual;
datetime dataTopoAnterior;

double   precoFundoAtual;
double   precoFundoAnterior;
datetime dataFundoAtual;
datetime dataFundoAnterior;

datetime tempoCandleBuffer[]; //falta esse vetor no slide

double   precoCompra ;
double   precoVenda ;


int idRobo = 123456789 ;

input int zzProfundidade = 14;
input double volumeOperacao = 1;
input datetime mercadoHoraInicio = "09:30:00" ;
input datetime mercadoHoraFim = "17:30:00" ;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   zzHandle = iCustom(_Symbol, _Period, "::Indicators\\Examples\\ZigZag.ex5", zzProfundidade);
   if(zzHandle == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag: ", GetLastError());
      return(INIT_FAILED);
   }

   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer, true);
   ArraySetAsSeries(zzFundoBuffer, true);
   ArraySetAsSeries(zzDataFundo, true);
   ArraySetAsSeries(zzDataTopo, true);

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
void OnDeinit(const int reason)
{
   IndicatorRelease(zzHandle);

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   // Se o horário não confere com o setup, fechar todas as posições e ordens
   if(TimeCurrent() < mercadoHoraInicio && TimeCurrent() > mercadoHoraFim) {
      // fecharTodasOrdensPendentesRobo;
      // fecharTodasPosicoesRobo;
      return;
   }

   // Se o ativo ainda não estiver sincronizado, retornar.
   if(!ativoInfo.IsSynchronized()) {
      return ;
   }

   // copia os topos
   if(CopyBuffer(zzHandle, 1, 0, totalCopiarBuffer, zzTopoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos topos: ", GetLastError());
      return;
   }

   // copia os fundos
   if(CopyBuffer(zzHandle, 2, 0, totalCopiarBuffer, zzFundoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos fundos: ", GetLastError());
      return;
   }

   // Copiar datas e horas dos fundos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataFundo) < 0) {
      Print("ERRO ao copiar datas");
      return;
   }

   // Copiar datas e horas dos topos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataTopo) < 0) {
      Print("ERRO ao copiar datas");
      return;
   }

   string nomeIcone = "icone";

   int nrTopo = 0;
   int nrFundo = 0 ;
   int tamArrayTopo = ArraySize(zzTopoBuffer);
   int tamArrayFundo = ArraySize(zzFundoBuffer);


   // Laço para buscar os topos
   for(int i = 0 ; i < tamArrayTopo ; i++) {

      // processar topos
      if( zzTopoBuffer[i] != 0 ) {
         if( nrTopo == 0 ) {
            precoTopoAtual = zzTopoBuffer[i];
            dataTopoAtual = zzDataTopo[i];
            nomeIcone = "topoAtual";
            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            desenharIcone(nomeIcone, precoTopoAtual, dataTopoAtual, clrRed, 233, 1);

         } else if( nrTopo == 1) {
            precoTopoAnterior = zzTopoBuffer[i];
            dataTopoAnterior = zzDataTopo[i];
            nomeIcone = "topoAnterior";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            desenharIcone(nomeIcone, precoTopoAnterior, dataTopoAnterior, clrBlue, 233, 1);

            break;
         } // Fim da condição para obter o topo anterior

         nrTopo++; // Incrementar um número ao topo para que na próxima, pegue o topo anterior
      } // fim do processar topos
   } //Fim do laço para obter topos e topos


   // Laço para buscar os fundos
   for(int i = 0 ; i < tamArrayFundo ; i++) {
      // processar fundos
      if( zzFundoBuffer[i] != 0 ) {
         if( nrFundo == 0 ) {
            precoFundoAtual = zzFundoBuffer[i];
            dataFundoAtual = zzDataFundo[i];
            nomeIcone = "fundoAtual";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrRed, 234, 1);

         } else if( nrFundo == 1) {
            precoFundoAnterior = zzFundoBuffer[i];
            dataFundoAnterior = zzDataFundo[i];
            nomeIcone = "fundoAnterior";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            desenharIcone(nomeIcone, precoFundoAnterior, dataFundoAnterior, clrBlue, 234, 1);

            break;
         } // Fim da condição para obter o topo anterior
         nrFundo++; // Incrementar um número ao fundo para que na próxima, pegue o fundo anterior
      } // fim do processar fundos
   } //Fim do laço para obter topos e fundos


   if(dataTopoAtual < dataFundoAtual) {
      // Print("Compra");
      // Cálculos de volume
      double volumeAnterior = somarVolume(dataTopoAnterior, dataFundoAtual);
      double volumeAtual = somarVolume(dataFundoAtual, dataTopoAtual);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      // Preço atual do ativo
      double precoAtual = ativoInfo.Last();

      double stopLoss = precoFundoAnterior;
      double precoCompraRegiao1 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * 0.6180) ;
      double precoCompraRegiao2 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * 0.9890) ;
      double takeProfit = ((precoCompraRegiao1 + precoCompraRegiao2) /2) + (precoTopoAtual - precoFundoAnterior);

      /*
         Abrir ordem, somente se:
         ------------------------
         -> não houver outra aberta
         -> se a indicação de volume é favorável
      */
      if(precoAtual >= precoCompraRegiao1 && precoAtual <= precoCompraRegiao2) {
         abrirOrdem(ORDER_TYPE_BUY, ativoInfo.Ask(), volumeOperacao, stopLoss, takeProfit, "compra");
      }
   } else {
      // Print("Venda");
      // Cálculos de volume
      double volumeAnterior = somarVolume(dataTopoAnterior, dataFundoAtual);
      double volumeAtual = somarVolume(dataFundoAtual, dataTopoAtual);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      // Preço atual do ativo
      double precoAtual = ativoInfo.Last();

      double stopLoss = precoTopoAnterior ;
      double precoVendaRegiao1 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * 0.6180) ;
      double precoVendaRegiao2 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * 0.9890) ;
      double takeProfit = ((precoVendaRegiao1 + precoVendaRegiao2)/2) + (precoTopoAnterior - precoFundoAtual) ;

      /*
         Abrir ordem de Venda se:
         -> Se o preço atual do ativo estiver dentro da região esperada;
         -> Se o volume anterior for maior do que o atual;
         -> Se não houver outra ordem de venda aberta;
      */
      if( precoAtual >= precoVendaRegiao1 && precoAtual <= precoVendaRegiao2 && volumeAnterior > volumeAtual ) {
         abrirOrdem(ORDER_TYPE_SELL, ativoInfo.Bid(), volumeOperacao, stopLoss, takeProfit, "venda");
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double somarVolume(datetime dataInicial, datetime dataFinal)
{
   int totalCopiado = CopyRealVolume(_Symbol, _Period, dataInicial, dataFinal, volumeBuffer);
   if( totalCopiado < 0) {
      return -1;
   }

   double somaVolume = 0;
   for(int i = 0; i < totalCopiado; i++) {
      somaVolume += volumeBuffer[i];
   }

   return somaVolume;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void abrirOrdem(ENUM_ORDER_TYPE tipoOrdem, double preco, double volume, double sl = 0, double tp = 0, string coment = "")
{

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fecharTodasPosicoesRobo()
{
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obterHistoricoNegociacaoRobo()
{

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
void fecharTodasOrdensPendentesRobo()
{
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



// ---------------------------------------------------------------------
// Método responsável por remover o icone de todo do gráfico pelo nome
// ---------------------------------------------------------------------
void removerIcone(string nome)
{

// remove
   ObjectDelete(0, nome);

// Print("REMOVER: ", nome);
   ChartRedraw();

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void desenharIcone (string nome, double preco, datetime data, color cor, int codigoIcone, int tamIcone)
{

   icone.Create(0, nome, 0, data, preco, codigoIcone) ;
   icone.Color(cor);
   icone.Width(tamIcone);

}
//+------------------------------------------------------------------+
