//+------------------------------------------------------------------+
//|                                               PBV-Elliot-001.mq5 |
//|                                                   Gerson Pereira |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Gerson Pereira"
#property link      "https://www.mql5.com"
#property version   "2.08"
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

datetime tempoCandleBuffer[];
int idRobo = 123456789 ;

int      totalCopiarBuffer = 100;

// Variáveis das ondas maiores
long     volumeBuffer[];
double   zzTopoBuffer[];
double   zzFundoBuffer[];
datetime zzDataFundo[];
datetime zzDataTopo[];
int      zzHandle;
input int zzProfundidade = 12; // Profundida das ondas maiores

// Variáveis das ondas menores (ondas dentro das ondas maiores)
long     volumeBuffer2[];
double   zzTopoBuffer2[];
double   zzFundoBuffer2[];
datetime zzDataFundo2[];
datetime zzDataTopo2[];
int      zzHandle2;
input int zzProfundidade2 = 3 ; // Profundida das ondas menores

// Região para entrada das operações
input double regiaoPrecoInicio = 0.786; // Região de preço de início
input double regiaoPrecoFim = 0.886; // Região de preço de fim


input double volumeOperacao = 1; // Volume a ser operado
input datetime mercadoHoraInicio = "09:10:00" ; // Hora de início das operações
input datetime mercadoHoraFim = "17:50:00" ; // Hora de fim das operações


bool isPosicaoAberta = false;
ENUM_POSITION_TYPE tipoPosicaoAberta ;

double takeProfit = 0;
double stopLoss = 0;
int deltaStop = 0;
input double deltaStopPercentual = 0.2360; // Percentual do Delta Stop
double traillingStop = 0 ;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   zzHandle = iCustom(_Symbol, _Period, "::Indicators\\Examples\\ZigZag.ex5", zzProfundidade);
   if(zzHandle == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag: ", GetLastError());
      return(INIT_FAILED);
   }

   zzHandle2 = iCustom(_Symbol, _Period, "::Indicators\\Examples\\ZigZag.ex5", zzProfundidade2 );
   if(zzHandle2 == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag menor: ", GetLastError());
      return(INIT_FAILED);
   }


   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer, true);
   ArraySetAsSeries(zzFundoBuffer, true);
   ArraySetAsSeries(zzDataFundo, true);
   ArraySetAsSeries(zzDataTopo, true);


   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer2, true);
   ArraySetAsSeries(zzFundoBuffer2, true);
   ArraySetAsSeries(zzDataFundo2, true);
   ArraySetAsSeries(zzDataTopo2, true);


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
   fecharTodasOrdensPendentesRobo();
   fecharTodasPosicoesRobo();

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---

   // Se o horário não confere com o setup, fechar todas as posições e ordens
   if(TimeCurrent() < mercadoHoraInicio && TimeCurrent() > mercadoHoraFim) {
      fecharTodasOrdensPendentesRobo();
      fecharTodasPosicoesRobo();
      return;
   }

   //Comment("Data atual: ", TimeCurrent(), " HORA INICIO: ", mercadoHoraInicio, "  HORA FIM: ", mercadoHoraFim);

   // Se o ativo ainda não estiver sincronizado, retornar.
   if(!ativoInfo.IsSynchronized()) {
      return ;
   }

   /*
      +------------------------------------------+
      | Tratamento dos buffers das ONDAS MAIORES |
      +------------------------------------------+
   */

   // copia os topos das ondas maiores
   if(CopyBuffer(zzHandle, 1, 0, totalCopiarBuffer, zzTopoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos topos das ondas maiores: ", GetLastError());
      return;
   }

   // copia os fundos das ondas maiores
   if(CopyBuffer(zzHandle, 2, 0, totalCopiarBuffer, zzFundoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos fundos das ondas maiores: ", GetLastError());
      return;
   }

   // Copiar datas e horas dos topos das ondas maiores
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataTopo) < 0) {
      Print("ERRO ao copiar datas topos das ondas maiores");
      return;
   }

   // Copiar datas e horas dos fundos das ondas maiores
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataFundo) < 0) {
      Print("ERRO ao copiar datas fundos das ondas maiores");
      return;
   }


   /*
      +------------------------------------------+
      | Tratamento dos buffers das ONDAS MENORES |
      +------------------------------------------+
   */

   // copia os topos das ondas menores
   if(CopyBuffer(zzHandle2, 1, 0, totalCopiarBuffer, zzTopoBuffer2) < 0 ) {
      Print("Erro ao copiar dados dos topos das ondas menores: ", GetLastError());
      return;
   }

   // copia os fundos das ondas menores
   if(CopyBuffer(zzHandle2, 2, 0, totalCopiarBuffer, zzFundoBuffer2) < 0 ) {
      Print("Erro ao copiar dados dos fundos das ondas menores: ", GetLastError());
      return;
   }

   // Copiar datas e horas dos topos das ondas menores
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataTopo2) < 0) {
      Print("ERRO ao copiar datas topos das ondas menores");
      return;
   }

   // Copiar datas e horas dos fundos das ondas menores
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataFundo2) < 0) {
      Print("ERRO ao copiar datas fundos das ondas menores");
      return;
   }






   string nomeIcone = "icone";

   int nrTopoA = 0;
   int nrFundoA = 0 ;

   int nrTopoB = 0;
   int nrFundoB = 0 ;


   int tamArrayTopo = ArraySize(zzTopoBuffer);
   int tamArrayFundo = ArraySize(zzFundoBuffer);

   int tamArrayTopo2 = ArraySize(zzTopoBuffer2);
   int tamArrayFundo2 = ArraySize(zzFundoBuffer2);


   // Topo da Onda Maior
   double   precoTopoAtual;
   double   precoTopoAnterior;
   double   precoTopoAnteriorC;

   datetime dataTopoAtual;
   datetime dataTopoAnterior;
   datetime dataTopoAnteriorC;


   //Topo da Onda Menor
   double   precoTopoAtual2;
   double   precoTopoAnterior2;
   datetime dataTopoAtual2;
   datetime dataTopoAnterior2;


   // Fundo Onda Maior
   double   precoFundoAtual;
   double   precoFundoAnterior;
   double   precoFundoAnteriorC;

   datetime dataFundoAtual;
   datetime dataFundoAnterior;
   datetime dataFundoAnteriorC;


   // Fundo da Onda menor
   double   precoFundoAtual2;
   double   precoFundoAnterior2;
   datetime dataFundoAtual2;
   datetime dataFundoAnterior2;

   /*
      +-----------------------------------------+
      | Buscar topos e fundos das ondas MAIORES |
      +-----------------------------------------+
   */
   // Laço para buscar os topos das ondas maiores
   for(int i = 0 ; i < tamArrayTopo ; i++) {

      // processar topos das ondas maiores
      if( zzTopoBuffer[i] != 0 ) {
         if( nrTopoA == 0 ) {
            precoTopoAtual = zzTopoBuffer[i];
            dataTopoAtual = zzDataTopo[i];

         } else if( nrTopoA == 1) {
            precoTopoAnterior = zzTopoBuffer[i];
            dataTopoAnterior = zzDataTopo[i];

         } else if( nrTopoA == 2) {
            precoTopoAnteriorC = zzTopoBuffer[i];
            dataTopoAnteriorC = zzDataTopo[i];
            break;
         } // Fim da condição para obter o topo anterior

         nrTopoA++; // Incrementar um número ao topo para que na próxima, pegue o topo anterior
      } // fim do processar topos
   } //Fim do laço para obter topos e topos


   // Laço para buscar os fundos das ondas maiores
   for(int i = 0 ; i < tamArrayFundo ; i++) {
      // processar fundos
      if( zzFundoBuffer[i] != 0 ) {
         if( nrFundoA == 0 ) {
            precoFundoAtual = zzFundoBuffer[i];
            dataFundoAtual = zzDataFundo[i];
         } else if( nrFundoA == 1) {
            precoFundoAnterior = zzFundoBuffer[i];
            dataFundoAnterior = zzDataFundo[i];

         } else if( nrFundoA == 2) {
            precoFundoAnteriorC = zzFundoBuffer[i];
            dataFundoAnteriorC = zzDataFundo[i];
            break;
         } // Fim da condição para obter o topo anterior
         nrFundoA++; // Incrementar um número ao fundo para que na próxima, pegue o fundo anterior
      } // fim do processar fundos
   } //Fim do laço para obter topos e fundos




   /*
      +-----------------------------------------+
      | Buscar topos e fundos das ondas MENORES |
      +-----------------------------------------+
   */
   // Laço para buscar os topos das ondas menores
   for(int i = 0 ; i < tamArrayTopo2 ; i++) {

      // processar topos das ondas menores
      if( zzTopoBuffer2[i] != 0 ) {
         if( nrTopoB == 0 ) {
            precoTopoAtual2 = zzTopoBuffer2[i];
            dataTopoAtual2 = zzDataTopo2[i];

         } else if( nrTopoB == 1) {
            precoTopoAnterior2 = zzTopoBuffer2[i];
            dataTopoAnterior2 = zzDataTopo2[i];
            break;
         } // Fim da condição para obter o topo anterior

         nrTopoB++; // Incrementar um número ao topo para que na próxima, pegue o topo anterior
      } // fim do processar topos
   } //Fim do laço para obter topos e topos


   // Laço para buscar os fundos das ondas menores
   for(int i = 0 ; i < tamArrayFundo2 ; i++) {
      // processar fundos
      if( zzFundoBuffer2[i] != 0 ) {
         if( nrFundoB == 0 ) {
            precoFundoAtual2 = zzFundoBuffer2[i];
            dataFundoAtual2 = zzDataFundo2[i];
         } else if( nrFundoB == 1) {
            precoFundoAnterior2 = zzFundoBuffer2[i];
            dataFundoAnterior2 = zzDataFundo2[i];
            break;
         } // Fim da condição para obter o topo anterior
         nrFundoB++; // Incrementar um número ao fundo para que na próxima, pegue o fundo anterior
      } // fim do processar fundos
   } //Fim do laço para obter topos e fundos




   // Atualizar informações do ativo
   ativoInfo.Refresh();
   ativoInfo.RefreshRates();


   if(dataFundoAtual > dataTopoAtual) {

      /*
         +--------------------+
         | Operação de COMPRA |
         +--------------------+
      */

      // Cálculos de volume para ser usado juntamente com as decisões nas regiões de entrada de operações
      double volumeAnterior = somarVolume(dataFundoAnterior, dataTopoAtual);
      double volumeAtual = somarVolume(dataTopoAtual, dataFundoAtual);

      //double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      double precoAtual = ativoInfo.Last();

      // Definições das regiões de entrada para operações de compra
      double precoCompraRegiao1 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * regiaoPrecoInicio) ;
      double precoCompraRegiao2 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * regiaoPrecoFim) ;

      deltaStop = (precoTopoAtual - precoFundoAnterior) * deltaStopPercentual ;

      double valorStopLoss = NormalizeDouble(precoFundoAnterior - deltaStop, _Digits);
      stopLoss = NormalizeDouble(MathRound(valorStopLoss / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);

      double valorTakeProfit = NormalizeDouble( precoAtual + (precoTopoAtual - precoFundoAnterior), _Digits) ;
      takeProfit = NormalizeDouble(MathRound(valorTakeProfit / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);

      if(   precoAtual <= precoCompraRegiao1
            && precoAtual >= precoCompraRegiao2
            && volumeAnterior > volumeAtual
            && precoFundoAtual > precoFundoAnterior
            && !(    precoTopoAnterior > precoTopoAnteriorC
                     && precoTopoAnterior > precoTopoAtual)) {

         if( buscarPosicaoAbertasByTipo(POSITION_TYPE_SELL) == false && buscarPosicaoAbertasByTipo(POSITION_TYPE_BUY) == false ) {
            desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrBlue, 221, 1);

            // Buscar o valor mínimo do lote do ativo e multplica pelo valor definido pelo usuário
            double volOrdem = ativoInfo.LotsMin() * volumeOperacao;

            //Comment("\n\nR1: ", (precoTopoAtual - precoFundoAnterior) * regiaoPrecoInicio, " R2: ", (precoTopoAtual - precoFundoAnterior) * regiaoPrecoFim );
            abrirOrdem(ORDER_TYPE_BUY, ativoInfo.Ask(), volOrdem, stopLoss, 0, "compra - R1 " + DoubleToString(precoCompraRegiao1 * regiaoPrecoInicio, 1) + "%  R2: " +  DoubleToString(precoCompraRegiao2 * regiaoPrecoFim, 1) + "%" );
         }
      }

   } else {
      /*
         +--------------------+
         | Operação de VENDA  |
         +--------------------+
      */
      double volumeAnterior = somarVolume(dataTopoAnterior, dataFundoAtual);
      double volumeAtual = somarVolume(dataFundoAtual, dataTopoAtual);

      double precoAtual = ativoInfo.Last();
      double precoVendaRegiao1 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * regiaoPrecoInicio) ;
      double precoVendaRegiao2 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * regiaoPrecoFim) ;

      deltaStop = (precoTopoAnterior - precoFundoAtual) * deltaStopPercentual ;

      double valorStopLoss = NormalizeDouble(precoTopoAnterior + deltaStop, _Digits);
      stopLoss = NormalizeDouble(MathRound(valorStopLoss / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);

      double valorTakeProfit = NormalizeDouble( precoAtual - (precoTopoAnterior - precoFundoAtual), _Digits) ;
      takeProfit = NormalizeDouble(MathRound(valorTakeProfit / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);

      if( precoAtual >= precoVendaRegiao1 && precoAtual <= precoVendaRegiao2 && volumeAnterior > volumeAtual
            && precoTopoAtual < precoTopoAnterior && !(precoFundoAnterior < precoFundoAnteriorC && precoFundoAnterior < precoFundoAtual)) {

         if( buscarPosicaoAbertasByTipo(POSITION_TYPE_SELL) == false && buscarPosicaoAbertasByTipo(POSITION_TYPE_BUY) == false) {
            //desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrRed, 222, 1);

            // Buscar o valor mínimo do lote do ativo e multplica pelo valor definido pelo usuário
            double volOrdem = ativoInfo.LotsMin() * volumeOperacao;

            // Comment("\n\nR1: ", (precoTopoAnterior - precoFundoAtual) * regiaoPrecoInicio, " R2: ",  (precoTopoAnterior - precoFundoAtual) * regiaoPrecoFim  );
            abrirOrdem(ORDER_TYPE_SELL, ativoInfo.Bid(), volOrdem, stopLoss, 0, "venda - R1 " + DoubleToString(precoVendaRegiao1 * regiaoPrecoInicio, 1) + "%  R2: " +  DoubleToString(precoVendaRegiao2 * regiaoPrecoFim, 1) + "%" );

         }
      }
   }


   //-------------------------------------------
   // Trailling stop
   if( isPosicaoAberta ) {

      // caso compra
      if( tipoPosicaoAberta == POSITION_TYPE_BUY) {
         // preço atual for maior do que o fundo da onda atual menor muda o trailling

         if( ativoInfo.Last() > precoFundoAtual2 ) {

            deltaStop = NormalizeDouble((precoTopoAtual - precoFundoAnterior) * deltaStopPercentual, _Digits) ;

            double valorStopLoss = NormalizeDouble(precoFundoAtual2 -  deltaStop, _Digits);
            stopLoss = NormalizeDouble(MathRound(valorStopLoss / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);

            trade.PositionModify(_Symbol, NormalizeDouble( 20, _Digits), 0);

         } 

      } else {
         // caso venda
         // preço atual for menor do que o topo da onda atual menor muda o trailling
         if( ativoInfo.Last() < precoTopoAtual2 ) {

            deltaStop = NormalizeDouble((precoTopoAnterior - precoFundoAtual) * deltaStopPercentual, _Digits) ;

            double valorStopLoss = NormalizeDouble(precoTopoAtual2 + deltaStop, _Digits);
            stopLoss = NormalizeDouble(MathRound(valorStopLoss / ativoInfo.TickSize()) * ativoInfo.TickSize(), _Digits);

            trade.PositionModify(_Symbol, NormalizeDouble( 20, _Digits), 0);

         }

      }

      //Print("Last:", ativoInfo.Last(), " - TS:", traillingStop);

   }// fim trailling


}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double somarVolume(datetime dataInicial, datetime dataFinal) {
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
void abrirOrdem(ENUM_ORDER_TYPE tipoOrdem, double preco, double volume, double sl, double tp, string coment = "") {

   //+-------------------------------------------------------+
   bool result  ; // variável não inicializada no slide
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



// ---------------------------------------------------------------------
// Método responsável por remover o icone de todo do gráfico pelo nome
// ---------------------------------------------------------------------
void removerIcone(string nome) {

// remove
   ObjectDelete(0, nome);

// Print("REMOVER: ", nome);
   ChartRedraw();

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void desenharIcone (string nome, double preco, datetime data, color cor, int codigoIcone, int tamIcone) {

   icone.Create(0, nome, 0, data, preco, codigoIcone) ;
   icone.Color(cor);
   icone.Width(tamIcone);

}
//+------------------------------------------------------------------+



//----------------------------------------------------------------------+
// Função responsável por verificar se há posições abertas por tipo.    |
//----------------------------------------------------------------------+
bool buscarPosicaoAbertasByTipo(ENUM_POSITION_TYPE tipoPosicaoBusca) {

   isPosicaoAberta = false;

   int totalPosicoes = PositionsTotal();
   //Print("POSICOES ABERTAS: " + totalPosicoes + " - Tipo posicao busca: " + EnumToString(tipoPosicaoBusca) );
   double lucroPosicao;

   for(int i = 0; i < totalPosicoes; i++) {

      // obtém o nome do símbolo a qual a posição foi aberta
      string simbolo = PositionGetSymbol(i);

      if(simbolo != "") {

         // id do robô
         ulong  magic = PositionGetInteger(POSITION_MAGIC);
         lucroPosicao = PositionGetDouble(POSITION_PROFIT);
         ENUM_POSITION_TYPE tipoPosicaoAberta = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         // obtém o simbolo da posição
         string simboloPosicao = PositionGetString(POSITION_SYMBOL);

         // se é o robô e ativo em questão
         if( simboloPosicao == _Symbol && magic == idRobo) {

            // caso operação
            if(tipoPosicaoBusca == tipoPosicaoAberta) {

               isPosicaoAberta = true;
               tipoPosicaoAberta = tipoPosicaoBusca;

               //Print("RETORNO POSICAO ABERTA: " + EnumToString(tipoPosicaoAberta) + " - ROBO: " + magic);
               //Print("TEM VENDA");
               return true;
            } else {
               tipoPosicaoBusca = NULL;
               isPosicaoAberta = false;
            }
         } // fim magic

      } else {
         PrintFormat("Erro quando recebeu a posição do cache com o indice %d." + " Error code: %d", i, GetLastError());
         ResetLastError();
      }

   } // fim for

   return false;

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

