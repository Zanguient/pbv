//+------------------------------------------------------------------+
//|                                 vt-aula-006-resumo_operacoes.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//---

   //declaração de variáveis
   datetime dataInicio, dataFim ;
   double lucro = 0, perda = 0;
   int trades = 0;
   double resultado ;
   ulong ticket ;


   //obter histórico
   MqlDateTime inicio_struct ;
   dataFim = TimeCurrent(inicio_struct);

   inicio_struct.hour = 0 ;
   inicio_struct.min = 0 ;
   inicio_struct.sec = 0 ;
   dataInicio = StructToTime(inicio_struct);



   //cálculos
   HistorySelect(dataInicio, dataFim);
   for(int i=0; i<HistoryDealsTotal(); i++) {
      ticket = HistoryDealGetTicket(i);
      if(ticket > 0) {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol) {
            trades++;
            resultado = HistoryDealGetDouble(ticket,DEAL_PROFIT);
            if(resultado < 0) {
               perda += -resultado ;
            } else {
               lucro += resultado ;
            }
         }
      }
   }


   double fator_lucro;
   if(perda > 0) {
      fator_lucro = lucro/perda;
   } else {
      fator_lucro = -1 ;
   }
   
   double resultado_liquido = lucro - perda ;






   //exibição
   
   Comment(
      " Trades: ", trades,
      " Lucro: ", DoubleToString(lucro, 2),
      " Perdas: ", DoubleToString(perda, 2),
      " Resultado : ", DoubleToString(resultado_liquido, 2),
      " Fator de Lucro : ", DoubleToString(fator_lucro, 2)
       );


}
//+------------------------------------------------------------------+
