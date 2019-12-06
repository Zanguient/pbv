//+------------------------------------------------------------------+
//|                                        slide-201-MqlBookInfo.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\SymbolInfo.mqh>
CSymbolInfo infoAtivo;



int OnInit() {

   if( !MarketBookAdd( _Symbol ) ) {

      Print("Erro ao realizar a abertura do DOM: ", GetLastError(), " !" );
      return INIT_FAILED ;
   }
   return INIT_SUCCEEDED;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit( const int reason) {
   MarketBookRelease( _Symbol );
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
   if(!MarketBookAdd(_Symbol)) {
      Print("Erro ao realizar a abertura do DOM: ", GetLastError(), "!");
      return ;
   }

   MqlBookInfo priceArray[];
   bool getBook = MarketBookGet(_Symbol, priceArray);

   if(getBook) {
      int size = ArraySize(priceArray);
      Print("MarketBookInfo do ativo ", _Symbol, " - Tamanho : ", size );
      for(int i=0; i < size; i++) {
         MqlBookInfo info = priceArray[i];
         Print(i + ":", info.price + " - Volume: " + info.volume, " - Tipo: ", info.type);

      }
   } else {
      Print(" Erro ao obter dados do DOM do ativo: ", _Symbol);
   }

}
//+------------------------------------------------------------------+
