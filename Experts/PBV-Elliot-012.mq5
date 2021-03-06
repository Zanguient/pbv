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

datetime tempoCandleBuffer[];
int idRobo = 123456789 ;

long     volumeBuffer[];
//long     volumeBufferB[];

double   zzTopoBuffer[];
//double   zzTopoBufferB[];

double   zzFundoBuffer[];
//double   zzFundoBufferB[];

datetime zzDataFundo[];
//datetime zzDataFundoB[];

datetime zzDataTopo[];
//datetime zzDataTopoB[];

int      totalCopiarBuffer = 50;
int      zzHandle;
//int      zzHandleB;




input int zzProfundidade = 12;
//input int zzProfundidadeB = 14;

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
/*
   zzHandleB = iCustom(_Symbol, _Period, "::Indicators\\Examples\\ZigZag.ex5", zzProfundidadeB);
   if(zzHandleB == INVALID_HANDLE) {
      Print("Falha ao criar o indicador ZigZag B: ", GetLastError());
      return(INIT_FAILED);
   }

*/
   // define para acessar como timeseries
   ArraySetAsSeries(zzTopoBuffer, true);
   ArraySetAsSeries(zzFundoBuffer, true);
   ArraySetAsSeries(zzDataFundo, true);
   ArraySetAsSeries(zzDataTopo, true);

/*   // B
   ArraySetAsSeries(zzTopoBufferB, true);
   ArraySetAsSeries(zzFundoBufferB, true);
   ArraySetAsSeries(zzDataFundoB, true);
   ArraySetAsSeries(zzDataTopoB, true);
*/
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
//   IndicatorRelease(zzHandleB);
   fecharTodasOrdensPendentesRobo();
   fecharTodasPosicoesRobo();

}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---

   // Se o horário não confere com o setup, fechar todas as posições e ordens
   if(TimeCurrent() < mercadoHoraInicio && TimeCurrent() > mercadoHoraFim) {
      fecharTodasOrdensPendentesRobo();
      fecharTodasPosicoesRobo();
      return;
   }

   // Se o ativo ainda não estiver sincronizado, retornar.
   if(!ativoInfo.IsSynchronized()) {
      return ;
   }

   // copia os topos
   if(CopyBuffer(zzHandle, 1, 0, totalCopiarBuffer, zzTopoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos topos A: ", GetLastError());
      return;
   }

   // copia os fundos
   if(CopyBuffer(zzHandle, 2, 0, totalCopiarBuffer, zzFundoBuffer) < 0 ) {
      Print("Erro ao copiar dados dos fundos A: ", GetLastError());
      return;
   }

/*
   // Copia os topos B
   if(CopyBuffer(zzHandleB, 1, 0, totalCopiarBuffer, zzTopoBufferB ) < 0 ) {
      Print("Erro ao copiar dados dos topos B: ", GetLastError());
      return;
   }


   // copia os fundos B
   if(CopyBuffer(zzHandleB, 2, 0, totalCopiarBuffer, zzFundoBufferB) < 0 ) {
      Print("Erro ao copiar dados dos fundos B: ", GetLastError());
      return;
   }
*/


   // Copiar datas e horas dos fundos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataFundo) < 0) {
      Print("ERRO ao copiar datas fundos A");
      return;
   }

   // Copiar datas e horas dos topos
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataTopo) < 0) {
      Print("ERRO ao copiar datas topos A");
      return;
   }


/*
   // Copiar datas e horas dos fundos B
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataFundoB) < 0) {
      Print("ERRO ao copiar datas fundos B");
      return;
   }

   // Copiar datas e horas dos topos B
   if(CopyTime(_Symbol, _Period, 0, totalCopiarBuffer, zzDataTopoB) < 0) {
      Print("ERRO ao copiar datas topos B");
      return;
   }
*/
   string nomeIcone = "icone";

   int nrTopoA = 0;
   int nrFundoA = 0 ;

   //int nrTopoB = 0;
   //int nrFundoB = 0 ;

   int tamArrayTopo = ArraySize(zzTopoBuffer);
   int tamArrayFundo = ArraySize(zzFundoBuffer);

   //int tamArrayTopoB = ArraySize(zzTopoBufferB);
   //int tamArrayFundoB = ArraySize(zzFundoBufferB);

   double   precoTopoAtual;
   double   precoTopoAnterior;
   datetime dataTopoAtual;
   datetime dataTopoAnterior;

   double   precoFundoAtual;
   double   precoFundoAnterior;
   datetime dataFundoAtual;
   datetime dataFundoAnterior;

   /*
   double   precoTopoAtualB;
   double   precoTopoAnteriorB;
   datetime dataTopoAtualB;
   datetime dataTopoAnteriorB;

   double   precoFundoAtualB;
   double   precoFundoAnteriorB;
   datetime dataFundoAtualB;
   datetime dataFundoAnteriorB;
   */

   // Laço para o ZigZag A
   //---------------------
   // Laço para buscar os topos
   for(int i = 0 ; i < tamArrayTopo ; i++) {

      // processar topos
      if( zzTopoBuffer[i] != 0 ) {
         if( nrTopoA == 0 ) {
            precoTopoAtual = zzTopoBuffer[i];
            dataTopoAtual = zzDataTopo[i];
            nomeIcone = "topoAtual";
            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoTopoAtual, dataTopoAtual, clrRed, 233, 1);

         } else if( nrTopoA == 1) {
            precoTopoAnterior = zzTopoBuffer[i];
            dataTopoAnterior = zzDataTopo[i];
            nomeIcone = "topoAnterior";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoTopoAnterior, dataTopoAnterior, clrBlue, 233, 1);

            break;
         } // Fim da condição para obter o topo anterior

         nrTopoA++; // Incrementar um número ao topo para que na próxima, pegue o topo anterior
      } // fim do processar topos
   } //Fim do laço para obter topos e topos


   // Laço para buscar os fundos
   for(int i = 0 ; i < tamArrayFundo ; i++) {
      // processar fundos
      if( zzFundoBuffer[i] != 0 ) {
         if( nrFundoA == 0 ) {
            precoFundoAtual = zzFundoBuffer[i];
            dataFundoAtual = zzDataFundo[i];
            nomeIcone = "fundoAtual";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrRed, 234, 1);

         } else if( nrFundoA == 1) {
            precoFundoAnterior = zzFundoBuffer[i];
            dataFundoAnterior = zzDataFundo[i];
            nomeIcone = "fundoAnterior";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoFundoAnterior, dataFundoAnterior, clrBlue, 234, 1);

            break;
         } // Fim da condição para obter o topo anterior
         nrFundoA++; // Incrementar um número ao fundo para que na próxima, pegue o fundo anterior
      } // fim do processar fundos
   } //Fim do laço para obter topos e fundos



   /*
   // Laço para o ZigZag B
   //---------------------

   // Laço para buscar os topos
   for(int i = 0 ; i < tamArrayTopoB ; i++) {

      // processar topos
      if( zzTopoBufferB[i] != 0 ) {
         if( nrTopoB == 0 ) {
            precoTopoAtualB = zzTopoBufferB[i];
            dataTopoAtualB = zzDataTopoB[i];
            nomeIcone = "topoAtualB";
            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoTopoAtualB, dataTopoAtualB, clrRed, 233, 1);

         } else if( nrTopoB == 1) {
            precoTopoAnteriorB = zzTopoBufferB[i];
            dataTopoAnteriorB = zzDataTopoB[i];
            nomeIcone = "topoAnteriorB";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoTopoAnteriorB, dataTopoAnteriorB, clrBlue, 233, 1);

            break;
         } // Fim da condição para obter o topo anterior

         nrTopoB++; // Incrementar um número ao topo para que na próxima, pegue o topo anterior
      } // fim do processar topos
   } //Fim do laço para obter topos e topos


   // Laço para buscar os fundos
   for(int i = 0 ; i < tamArrayFundoB ; i++) {
      // processar fundos
      if( zzFundoBufferB[i] != 0 ) {
         if( nrFundoB == 0 ) {
            precoFundoAtualB = zzFundoBufferB[i];
            dataFundoAtualB = zzDataFundoB[i];
            nomeIcone = "fundoAtualB";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoFundoAtualB, dataFundoAtualB, clrRed, 234, 1);

         } else if( nrFundoB == 1) {
            precoFundoAnteriorB = zzFundoBufferB[i];
            dataFundoAnteriorB = zzDataFundoB[i];
            nomeIcone = "fundoAnteriorB";

            //removerIcone( nomeIcone ); // PRECISA REMOVER APENAS PARA BACKTEST
            //desenharIcone(nomeIcone, precoFundoAnteriorB, dataFundoAnteriorB, clrBlue, 234, 1);

            break;
         } // Fim da condição para obter o topo anterior
         nrFundoB++; // Incrementar um número ao fundo para que na próxima, pegue o fundo anterior
      } // fim do processar fundos
   } //Fim do laço para obter topos e fundos



   // Analisar topos e fundos B
   //--------------------------

   if(dataTopoAtualB < dataFundoAnteriorB) {
      //Print("Compra");
      double volumeAnteriorB = somarVolume(dataFundoAnteriorB, dataTopoAtualB);
      double volumeAtualB = somarVolume(dataTopoAtualB, dataFundoAtualB);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      double precoAtualB = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      double precoCompraRegiao1B = precoTopoAtualB - ((precoTopoAtualB - precoFundoAnteriorB) * 0.6180) ;
      double precoCompraRegiao2B = precoTopoAtualB - ((precoTopoAtualB - precoFundoAnteriorB) * 0.9280) ;
      double stopLossB = precoFundoAnteriorB ;
      double takeProfitB = precoAtualB + (precoTopoAtualB - precoFundoAnteriorB) ;

   } else {
      //Print("Venda");
      double volumeAnteriorB = somarVolume(dataTopoAnteriorB, dataFundoAtualB);
      double volumeAtualB = somarVolume(dataFundoAtualB, dataTopoAtualB);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      double precoAtualB = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      double precoVendaRegiao1B = precoFundoAtualB + ((precoTopoAnteriorB - precoFundoAtualB) * 0.6180) ;
      double precoVendaRegiao2B = precoFundoAtualB + ((precoTopoAnteriorB - precoFundoAtualB) * 0.9280) ;
      double stopLossB = precoTopoAnteriorB ;
      double takeProfitB = precoAtualB - (precoTopoAnteriorB - precoFundoAtualB);
   }

   */

// Tratar com topos e fundos A
//----------------------------
   if(dataTopoAtual < dataFundoAnterior) {
      //Print("Compra");
      // Cálculos de volume
      double volumeAnterior = somarVolume(dataFundoAnterior, dataTopoAtual);
      double volumeAtual = somarVolume(dataTopoAtual, dataFundoAtual);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      // Preço atual do ativo
      double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      //Print("Compra: precoAtual:",precoAtual);

      double precoCompraRegiao1 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * 0.6180) ;
      double precoCompraRegiao2 = precoTopoAtual - ((precoTopoAtual - precoFundoAnterior) * 0.9280) ;
      double stopLoss = precoFundoAnterior ;
      double takeProfit = precoAtual + (precoTopoAtual - precoFundoAnterior) ;
      //Print("PA:", precoAtual, " - SL:", stopLoss, " - TP:", takeProfit, " - PCR1:", precoCompraRegiao1, " - PCR2:", precoCompraRegiao2);

      /*
         Abrir ordem de Compra se:
         -> Se o preço atual do ativo estiver dentro da região esperada;
         -> Se o volume anterior for maior do que o atual;
         -> Se não houver outra ordem de compra aberta;
      */
      //Print("precoAtual:",precoAtual," >= precoCompraRegiao1",precoCompraRegiao1," && precoAtual:",precoAtual," <= precoCompraRegiao2",precoCompraRegiao2);
      if( precoAtual >= precoCompraRegiao2 && precoAtual <= precoCompraRegiao1 && volumeAnterior > volumeAtual ) {
      //if( precoAtual >= precoCompraRegiao2 && precoAtual <= precoCompraRegiao1 ) {
         Print("Preço na região de COMPRA");
         if( buscarPosicaoAbertasByTipo(POSITION_TYPE_BUY) == false ) {
            //Print("Abrindo ordem de COMPRA");
            desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrBlue, 221, 1);
            //fecharTodasOrdensPendentesRobo();
            //fecharTodasPosicoesRobo();
            abrirOrdem(ORDER_TYPE_BUY, ativoInfo.Ask(), volumeOperacao, stopLoss, takeProfit, "compra");
         } else {
            //Print("Já EXISTE uma posição de COMPRA aberta");
         }
      } else {
         //Print("Compra: Preço ainda não está na região ou o volume anterior é maior");
      }
   } else {
      //Print("Venda");
      // Cálculos de volume
      double volumeAnterior = somarVolume(dataTopoAnterior, dataFundoAtual);
      double volumeAtual = somarVolume(dataFundoAtual, dataTopoAtual);

      // Atualizar informações do ativo
      ativoInfo.Refresh();

      double precoAtual = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
      double precoVendaRegiao1 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * 0.6180) ;
      double precoVendaRegiao2 = precoFundoAtual + ((precoTopoAnterior - precoFundoAtual) * 0.9280) ;
      double stopLoss = precoTopoAnterior ;
      double takeProfit = precoAtual - (precoTopoAnterior - precoFundoAtual);
      //Print("PA:", precoAtual, " - SL:", stopLoss, " - TP:", takeProfit, " - PVR1:", precoVendaRegiao1, " - PVR2:", precoVendaRegiao2);

      /*
         Abrir ordem de Venda se:
         -> Se o preço atual do ativo estiver dentro da região esperada;
         -> Se o volume anterior for maior do que o atual;
         -> Se não houver outra ordem de venda aberta;
      */
      //Print("VENDA: precoAtual:",precoAtual," >= precoVendaRegiao1",precoVendaRegiao1," && precoAtual:",precoAtual, " <= precoVendaRegiao2",precoVendaRegiao2);
      if( precoAtual >= precoVendaRegiao1 && precoAtual <= precoVendaRegiao2 && volumeAnterior > volumeAtual ) {
      //if( precoAtual >= precoVendaRegiao1 && precoAtual <= precoVendaRegiao2 ) {
         Print("Preço na região de VENDA");
         if(buscarPosicaoAbertasByTipo(POSITION_TYPE_SELL) == false ) {
            //Print("Abrindo ordem de venda");
            desenharIcone(nomeIcone, precoFundoAtual, dataFundoAtual, clrRed, 222, 1);
            //fecharTodasOrdensPendentesRobo();
            //fecharTodasPosicoesRobo();
            abrirOrdem(ORDER_TYPE_SELL, ativoInfo.Bid(), volumeOperacao, stopLoss, takeProfit, "venda");

         } else {
            //Print("Já EXISTE uma posição de VENDA aberta");
         }
      } else {
         //Print("Venda: Preço ainda não está na região ou o Volume anterior é maior");
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
void abrirOrdem(ENUM_ORDER_TYPE tipoOrdem, double preco, double volume, double sl, double tp, string coment = "")
{

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



//----------------------------------------------------------------------+
// Função responsável por verificar se há posições abertas por tipo.    |
//----------------------------------------------------------------------+
bool buscarPosicaoAbertasByTipo(ENUM_POSITION_TYPE tipoPosicaoBusca)
{

   int totalPosicoes = PositionsTotal();
   //Alert("POSICOES ABERTAS: " + totalPosicoes + " - Tipo posicao busca: " + EnumToString(tipoPosicaoBusca) );
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

               //Print("RETORNO POSICAO ABERTA: " + EnumToString(tipoPosicaoAberta) + " - ROBO: " + magic);
               //Print("TEM VENDA");
               return true;
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
