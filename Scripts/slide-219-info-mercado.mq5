//+------------------------------------------------------------------+
//|                                       slide-219-info-mercado.mq5 |
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
   int todosAtivos = SymbolsTotal(false); // true – somente que estão na janela de observação
   for(int i=0; i < todosAtivos; i++) {
      string nomeAtivo = SymbolName(i, false);
      SymbolSelect(nomeAtivo, true); // somente da janela de observação
      Sleep(500);
      double precoUltNegocio = SymbolInfoDouble(nomeAtivo, SYMBOL_LAST);
      double bid = SymbolInfoDouble(nomeAtivo, SYMBOL_BID);
      double ask = SymbolInfoDouble(nomeAtivo, SYMBOL_ASK);
      datetime dtHoraNegocio = (datetime)SymbolInfoInteger(nomeAtivo, SYMBOL_TIME);
      string descricao = SymbolInfoString(nomeAtivo, SYMBOL_DESCRIPTION);
      string nome = SymbolInfoString(nomeAtivo, SYMBOL_BASIS);
      Print(nome, " ", precoUltNegocio," ", dtHoraNegocio," ", bid," ", ask," ", descricao );
      SymbolSelect(nomeAtivo, false);
   }
}
//+------------------------------------------------------------------+
