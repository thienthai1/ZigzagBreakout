//+------------------------------------------------------------------+
//|                                           ZigzagBreakoutView.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

datetime lastBarTime = 0;
double lastZigzagHigh = 0;
double lastZigzagLow = 0;
input double lotSize = 0.1;
input double triggerLength = 300;
input double takeProfit = 300;
input double stopLoss = 600;
string sellLimitPrefix = "sell limit";
string buyLimitPrefix = "buy limit";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Remove lines when deinitializing
   ObjectDelete("Zigzag High Line");
   ObjectDelete("Zigzag Low Line");
   int totalObjects = ObjectsTotal();
    for (int i = totalObjects - 1; i >= 0; i--)
    {
        string objName = ObjectName(i);
        string descr = ObjectDescription(i);
        Print("view description ", descr);
        if (
        StringFind(objName, "deleted") != -1 ||
        StringFind(objName, "tester") == -1
        ) // Match names starting with arrowNamePrefix
        {
            if(StringFind(objName, "->") == -1){
                ObjectDelete(objName);
                //Print(StringFind(objName, "deleted"));
            }
        }
       
    }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {    
        // Get the time of the current bar
        datetime currentBarTime = iTime(NULL, 0, 0);
    
        // Check if the current bar is new (i.e., has a different time than the last processed bar)
        if (currentBarTime != lastBarTime)
        {
           int depth = 12;
           int deviation = 5;
           int backstep = 3;
           int range = 100; // Adjusted range to 100
           double zigzagHigh = GetHighestZigZagHigh(depth, deviation, backstep, range);
           double zigzagLow = GetLowestZigZagLow(depth, deviation, backstep, range);
           
           // Update the lines if the zigzag high or low changes
           if (zigzagHigh != lastZigzagHigh)
           {
               lastZigzagHigh = zigzagHigh;
               RemovePendingBuyOrders();
               PlaceSellLimit(zigzagHigh + triggerLength * Point, takeProfit, stopLoss);
           }
           
           if (zigzagLow != lastZigzagLow)
           {
               lastZigzagLow = zigzagLow;
               RemovePendingSellOrders();
               PlaceBuyLimit(zigzagLow - triggerLength * Point, takeProfit, stopLoss);
           }
           
           //Comment("Zigzag High: ", zigzagHigh, "\n", "Zigzag Low: ", zigzagLow);
           
           // Update the last bar time to the current bar time
           lastBarTime = currentBarTime;
           
           
        }
        
        CommentOutAllOrders();
   
  }
//+------------------------------------------------------------------+

double GetHighestZigZagHigh(int depth, int deviation, int backstep, int range) 
{
    double highestZigzagHigh = -1; // Initialize to a very low value
    
    for (int i = 0; i < range; i++)
    {
        double zigzagValue = iCustom(Symbol(), PERIOD_CURRENT, "ZigZag", depth, deviation, backstep, 1, i);
        if (zigzagValue > 0 && (highestZigzagHigh == -1 || zigzagValue > highestZigzagHigh))
        {
            highestZigzagHigh = zigzagValue;
        }
    }
    
    return highestZigzagHigh;
}

double GetLowestZigZagLow(int depth, int deviation, int backstep, int range) 
{
    double lowestZigzagLow = -1; // Initialize to a very high value
    
    for (int i = 0; i < range; i++)
    {
        double zigzagValue = iCustom(Symbol(), PERIOD_CURRENT, "ZigZag", depth, deviation, backstep, 2, i);
        if (zigzagValue > 0 && (lowestZigzagLow == -1 || zigzagValue < lowestZigzagLow))
        {
            lowestZigzagLow = zigzagValue;
        }
    }
    
    return lowestZigzagLow;
}

void DrawHorizontalLine(string name, double price, color lineColor)
{
    // Create or update the horizontal line
    if (ObjectFind(name) == -1)
    {
        ObjectCreate(0, name, OBJ_HLINE, 0, Time[0], price);
        ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
    }
    else
    {
        ObjectSetDouble(0, name, OBJPROP_PRICE1, price);
    }
}

void PlaceBuyStopOrder(double price, int tpPoints, int slPoints)
{
    double lotSize = lotSize; // Example lot size, adjust according to your needs
    double takeProfit = price + tpPoints * Point;
    double stopLoss = price - slPoints * Point;
    
    int ticket = OrderSend(Symbol(), OP_BUYSTOP, lotSize, price, 3, stopLoss, takeProfit, "Buy Stop Order", 0, 0, clrGreen);
    if (ticket < 0)
    {
        Print("Error placing Buy Stop order: ", GetLastError());
    }
}

void PlaceSellStopOrder(double price, int tpPoints, int slPoints)
{
    double lotSize = lotSize; // Example lot size, adjust according to your needs
    double takeProfit = price - tpPoints * Point;
    double stopLoss = price + slPoints * Point;
    
    int ticket = OrderSend(Symbol(), OP_SELLSTOP, lotSize, price, 3, stopLoss, takeProfit, "Sell Stop Order", 0, 0, clrRed);
    if (ticket < 0)
    {
        Print("Error placing Sell Stop order: ", GetLastError());
    }
}

void PlaceBuyLimit(double price, int tpPoints, int slPoints)
{
    double lotSize = lotSize; // Example lot size, adjust according to your needs
    double takeProfit = price + tpPoints * Point;
    double stopLoss = price - slPoints * Point;
    
    int ticket = OrderSend(Symbol(), OP_BUYLIMIT, lotSize, price, 3, stopLoss, takeProfit, "Buy Limit Order", 0, 0, clrGreen);
    if (ticket < 0)
    {
        Print("Error placing Buy Stop order: ", GetLastError());
    }
}

void PlaceSellLimit(double price, int tpPoints, int slPoints)
{
    double lotSize = lotSize; // Example lot size, adjust according to your needs
    double takeProfit = price - tpPoints * Point;
    double stopLoss = price + slPoints * Point;
    
    int ticket = OrderSend(Symbol(), OP_SELLLIMIT, lotSize, price, 3, stopLoss, takeProfit, "Sell Limit Order", 0, 0, clrRed);
    if (ticket < 0)
    {
        Print("Error placing Sell Stop order: ", GetLastError());
    }
}



void RemovePendingSellOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Remove only pending stop orders (Buy Stop and Sell Stop)
            if (OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT)
            {
                OrderDelete(OrderTicket());
            }
        }
    }
}

void RemovePendingBuyOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Remove only pending stop orders (Buy Stop and Sell Stop)
            if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLLIMIT)
            {
                OrderDelete(OrderTicket());
            }
        }
    }
}

void CommentOutAllOrders()
{
    int totalOrders = OrdersTotal();
    string commentText = "";
    
    for(int i = 0; i < totalOrders; i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            int orderType = OrderType();
            if(orderType == OP_BUY || orderType == OP_SELL)
            {
                commentText += "Order ID: " + IntegerToString(OrderTicket()) + "\n";
            }
        }
    }
    
    Comment(commentText);
}
