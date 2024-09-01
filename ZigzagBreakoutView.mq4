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
               DrawHorizontalLine("Zigzag High Line", zigzagHigh, clrRed);
           }
           
           if (zigzagLow != lastZigzagLow)
           {
               lastZigzagLow = zigzagLow;
               DrawHorizontalLine("Zigzag Low Line", zigzagLow, clrBlue);
           }
           
           Comment("Zigzag High: ", zigzagHigh, "\n", "Zigzag Low: ", zigzagLow);
           
           // Update the last bar time to the current bar time
           lastBarTime = currentBarTime;
        }
   
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
