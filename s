// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © StratifyTrade - formerly know as HunterAlgos

//@version=5
indicator("Price Action Concepts [StratifyTrade]", shorttitle = "Price Action Concepts [1.2.1]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500, max_polylines_count = 100)


//-----------------------------------------------------------------------------{
    //Boolean set
//-----------------------------------------------------------------------------{
s_BREAK      = 0
s_CHANGE     = 1
i_BREAK      = 2
i_CHANGE     = 3
i_pp_CHANGE  = 4
green_candle = 5
red_candle   = 6
s_CHANGEP    = 7
i_CHANGEP    = 8

boolean =
 array.from(
   false
 , false 
 , false 
 , false 
 , false 
 , false 
 , false 
 , false
 , false
 )


//-----------------------------------------------------------------------------{
    // User inputs
//-----------------------------------------------------------------------------{

show_swing_ms                   = input.string      ("All"                            , "Swing        "               , inline = "1", group = "MARKET STRUCTURE"            , options = ["All", "CHANGE", "CHANGE+", "BREAK", "None"])
show_internal_ms                = input.string      ("All"                            , "Internal     "               , inline = "2", group = "MARKET STRUCTURE"            , options = ["All", "CHANGE", "CHANGE+", "BREAK", "None"])
internal_r_lookback             = input.int         (5                                , ""                            , inline = "2", group = "MARKET STRUCTURE"            , minval = 2)
swing_r_lookback                = input.int         (50                               , ""                            , inline = "1", group = "MARKET STRUCTURE"            , minval = 2)
ms_mode                         = input.string      ("Manual"                         , "Market Structure Mode"       , inline = "a", group = "MARKET STRUCTURE"            , tooltip = "[Manual] Use selected lenght\n[Dynamic] Use automatic lenght" ,options = ["Manual", "Dynamic"])
show_mtf_str                    = input.bool        (true                             , "MTF Scanner"                 , inline = "9", group = "MARKET STRUCTURE"            , tooltip = "Display Multi-Timeframe Market Structure Trend Directions. Green = Bullish. Red = Bearish")
show_eql                        = input.bool        (false                            , "Show EQH/EQL"                , inline = "6", group = "MARKET STRUCTURE")
plotcandle_bool                 = input.bool        (false                            , "Plotcandle"                  , inline = "3", group = "MARKET STRUCTURE"            , tooltip = "Displays a cleaner colored candlestick chart in place of the default candles. (requires hiding the current ticker candles)")
barcolor_bool                   = input.bool        (false                            , "Bar Color"                   , inline = "4", group = "MARKET STRUCTURE"            , tooltip = "Color the candle bodies according to market strucutre trend")

i_ms_up_BREAK                   = input.color       (#089981                        , ""                            , inline = "2", group = "MARKET STRUCTURE")
i_ms_dn_BREAK                   = input.color       (#f23645                        , ""                            , inline = "2", group = "MARKET STRUCTURE")
s_ms_up_BREAK                   = input.color       (#089981                        , ""                            , inline = "1", group = "MARKET STRUCTURE")
s_ms_dn_BREAK                   = input.color       (#f23645                        , ""                            , inline = "1", group = "MARKET STRUCTURE")

lvl_daily                       = input.bool        (false                            , "Day   "                      , inline = "1", group = "HIGHS & LOWS MTF")
lvl_weekly                      = input.bool        (false                            , "Week "                       , inline = "2", group = "HIGHS & LOWS MTF")
lvl_monthly                     = input.bool        (false                            , "Month"                       , inline = "3", group = "HIGHS & LOWS MTF")
lvl_yearly                      = input.bool        (false                            , "Year  "                      , inline = "4", group = "HIGHS & LOWS MTF")
css_d                           = input.color       (color.blue                     , ""                            , inline = "1", group = "HIGHS & LOWS MTF")
css_w                           = input.color       (color.blue                     , ""                            , inline = "2", group = "HIGHS & LOWS MTF")
css_m                           = input.color       (color.blue                     , ""                            , inline = "3", group = "HIGHS & LOWS MTF")
css_y                           = input.color       (color.blue                     , ""                            , inline = "4", group = "HIGHS & LOWS MTF")
s_d                             = input.string      ('⎯⎯⎯'                            , ''                            , inline = '1', group = 'HIGHS & LOWS MTF'                , options = ['⎯⎯⎯', '----', '····'])
s_w                             = input.string      ('⎯⎯⎯'                            , ''                            , inline = '2', group = 'HIGHS & LOWS MTF'                , options = ['⎯⎯⎯', '----', '····'])
s_m                             = input.string      ('⎯⎯⎯'                            , ''                            , inline = '3', group = 'HIGHS & LOWS MTF'                , options = ['⎯⎯⎯', '----', '····'])
s_y                             = input.string      ('⎯⎯⎯'                            , ''                            , inline = '4', group = 'HIGHS & LOWS MTF'                , options = ['⎯⎯⎯', '----', '····'])

ob_show                         = input.bool        (true                             , "Show Last    "               , inline = "1", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Display volumetric order blocks on the chart \n\n[Input] Ammount of volumetric order blocks to show")
ob_num                          = input.int         (2                                , ""                            , inline = "1", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Orderblocks number", minval = 1, maxval = 10)
ob_metrics_show                 = input.bool        (true                             , "Internal Buy/Sell Activity"  , inline = "2", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Display volume metrics that have formed the orderblock")
css_metric_up                   = input.color       (color.new(#089981,  50)        , "         "                   , inline = "2", group = "VOLUMETRIC ORDER BLOCKS")
css_metric_dn                   = input.color       (color.new(#f23645 , 50)        , ""                            , inline = "2", group = "VOLUMETRIC ORDER BLOCKS")
ob_swings                       = input.bool        (false                            , "Swing Order Blocks"          , inline = "a", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Display swing volumetric order blocks")
css_swing_up                    = input.color       (color.new(color.gray  , 90)    , "                 "           , inline = "a", group = "VOLUMETRIC ORDER BLOCKS")
css_swing_dn                    = input.color       (color.new(color.silver, 90)    , ""                            , inline = "a", group = "VOLUMETRIC ORDER BLOCKS")
ob_filter                       = input.string      ("None"                           , "Filtering             "      , inline = "d", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Filter out volumetric order blocks by BREAK/CHANGE/CHANGE+", options = ["None", "BREAK", "CHANGE", "CHANGE+"])
ob_mitigation                   = input.string      ("Absolute"                       , "Mitigation           "       , inline = "4", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Trigger to remove volumetric order blocks", options = ["Absolute", "Middle"])
use_grayscale                   = input.bool        (false                            , "Grayscale"                   , inline = "6", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Use gray as basic order blocks color")
use_show_metric                 = input.bool        (true                             , "Show Metrics"                , inline = "7", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Show volume associated with the orderblock and his relevance")
use_middle_line                 = input.bool        (true                             , "Show Middle-Line"            , inline = "8", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Show mid-line order blocks")
use_overlap                     = input.bool        (true                             , "Hide Overlap"                , inline = "9", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "Hide overlapping order blocks")
use_overlap_method              = input.string      ("Previous"                       , "Overlap Method    "          , inline = "Z", group = "VOLUMETRIC ORDER BLOCKS"         , tooltip = "[Recent] Preserve the most recent volumetric order blocks\n\n[Previous] Preserve the previous volumetric order blocks", options = ["Recent", "Previous"])
ob_bull_css                     = input.color       (color.new(#089981 ,  90)       , ""                            , inline = "1", group = "VOLUMETRIC ORDER BLOCKS")
ob_bear_css                     = input.color       (color.new(#f23645 ,  90)       , ""                            , inline = "1", group = "VOLUMETRIC ORDER BLOCKS")

show_acc_dist_zone              = input.bool        (false                            , ""                            , inline = "1", group = "Accumulation And Distribution")
zone_mode                       = input.string      ("Fast"                           , ""                            , inline = "1", group = "Accumulation And Distribution"   , tooltip = "[Fast] Find small zone pattern formation\n[Slow] Find bigger zone pattern formation" ,options = ["Slow", "Fast"])
acc_css                         = input.color       (color.new(#089981   , 60)      , ""                            , inline = "1", group = "Accumulation And Distribution")
dist_css                        = input.color       (color.new(#f23645   , 60)      , ""                            , inline = "1", group = "Accumulation And Distribution")

show_lbl                        = input.bool        (false                            , "Show swing point"            , inline = "1", group = "High and Low"                    , tooltip = "Display swing point")
show_mtb                        = input.bool        (false                            , "Show High/Low/Equilibrium"   , inline = "2", group = "High and Low"                    , tooltip = "Display Strong/Weak High And Low and Equilibrium")
toplvl                          = input.color       (color.red                      , "Premium Zone   "             , inline = "3", group = "High and Low")
midlvl                          = input.color       (color.white                    , "Equilibrium Zone"            , inline = "4", group = "High and Low")
btmlvl                          = input.color       (#089981                        , "Discount Zone    "           , inline = "5", group = "High and Low")

fvg_enable                      = input.bool        (false                            , "        "                            , inline = "1", group = "FAIR VALUE GAP"          , tooltip = "Display fair value gap")
what_fvg                        = input.string      ("FVG"                            , ""                            , inline = "1", group = "FAIR VALUE GAP"                  , tooltip = "Display fair value gap", options = ["FVG", "VI", "OG"])
fvg_num                         = input.int         (5                                , "Show Last  "                   , inline = "1a", group = "FAIR VALUE GAP"               , tooltip = "Number of fvg to show")
fvg_upcss                       = input.color       (color.new(#089981,  80)        , ""                            , inline = "1", group = "FAIR VALUE GAP")
fvg_dncss                       = input.color       (color.new(color.red ,  80)     , ""                            , inline = "1", group = "FAIR VALUE GAP")
fvg_extend                      = input.int         (10                               , "Extend FVG"                  , inline = "2", group = "FAIR VALUE GAP"                  , tooltip = "Extend the display of the FVG.")
fvg_src                         = input.string      ("Close"                          , "Mitigation  "                , inline = "3", group = "FAIR VALUE GAP"                  , tooltip = "[Close] Use the close of the body as trigger\n\n[Wick] Use the extreme point of the body as trigger", options = ["Close", "Wick"])
fvg_tf                          = input.timeframe   (""                               , "Timeframe "                  , inline = "4", group = "FAIR VALUE GAP"                  , tooltip = "Timeframe of the fair value gap")

t                               = color.t           (ob_bull_css)
invcol                          = color.new         (color.white                    , 100)

































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - UDT                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

type bar
    float   o = open
    float   c = close
    float   h = high
    float   l = low
    float   v = volume
    int     n = bar_index
    int     t = time

type Zphl
    line   top
    line   bottom
    label  top_label
    label  bottom_label
    bool   stopcross
    bool   sbottomcross
    bool   itopcross
    bool   ibottomcross
    string txtup
    string txtdn
    float  topy
    float  bottomy
    float  topx
    float  bottomx
    float  tup
    float  tdn
    int    tupx
    int    tdnx
    float  itopy
    float  itopx
    float  ibottomy
    float  ibottomx

type FVG
    box [] box
    line[] ln
    bool   bull
    float  top
    float  btm
    int    left
    int    right

type ms
	float[] p
	int  [] n
    float[] l

type msDraw
	int    n
	float  p
	color  css
	string txt
	bool   bull

type obC 
    float[] top
    float[] btm
    int  [] left
    float[] avg
    float[] dV 
    float[] cV 
    int  [] wM 
    int  [] blVP 
    int  [] brVP 
    int  [] dir  
    float[] h
    float[] l
    int  [] n

type obD 
    box [] ob 
    box [] eOB
    box [] blB 
    box [] brB 
    line[] mL

type zone
    chart.point points
    float p
    int   c
    int   t

type hqlzone
    box   pbx
    box   ebx
    box   lbx
    label plb
    label elb
    label lbl

type ehl
    float pt
    int   t
    float pb
    int   b

type pattern
    string found = "None"
    bool isfound = false
    int   period = 0
    bool  bull   = false

type alerts
    bool chochswing     = false
    bool chochplusswing = false
    bool swingbos       = false
    bool chochplus      = false
    bool choch          = false
    bool bos            = false
    bool equal          = false
    bool ob             = false
    bool swingob        = false
    bool zone           = false
    bool fvg            = false

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - General Setup                                                                                                                              }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

bar         b      = bar.new()
var pattern p      = pattern.new()

alerts      blalert = alerts.new()
alerts      bralert = alerts.new()

if p.isfound

    p.period += 1

if p.period == 50

    p.period  := 0
    p.found   := "None"
    p.isfound := false
    p.bull    := na

switch

    b.c > b.o => boolean.set(green_candle, true)
    b.c < b.o => boolean.set(red_candle  , true)

f_zscore(src, lookback) =>

    (src - ta.sma(src, lookback)) / ta.stdev(src, lookback)

var int iLen = internal_r_lookback
var int sLen = swing_r_lookback

vv = f_zscore(((close - close[iLen]) / close[iLen]) * 100,iLen)

if ms_mode == "Dynamic"

    switch

        vv >= 1.5 or vv <= -1.5 => iLen := 10
        vv >= 1.6 or vv <= -1.6 => iLen := 9
        vv >= 1.7 or vv <= -1.7 => iLen := 8
        vv >= 1.8 or vv <= -1.8 => iLen := 7
        vv >= 1.9 or vv <= -1.9 => iLen := 6
        vv >= 2.0 or vv <= -2.0 => iLen := 5
        =>                         iLen

var msline = array.new<line>(0)

iH = ta.pivothigh(high, iLen, iLen)
sH = ta.pivothigh(high, sLen, sLen)
iL = ta.pivotlow (low , iLen, iLen)
sL = ta.pivotlow (low , sLen, sLen)

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - ARRAYS                                                                                                                                     }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

hl  () => [high, low]

[pdh, pdl] = request.security(syminfo.tickerid , 'D'  , hl() , lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid , 'W'  , hl() , lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid , 'M'  , hl() , lookahead = barmerge.lookahead_on)
[pyh, pyl] = request.security(syminfo.tickerid , '12M', hl() , lookahead = barmerge.lookahead_on)

lstyle(style) =>

    out = switch style

        '⎯⎯⎯'  => line.style_solid
        '----' => line.style_dashed
        '····' => line.style_dotted

mtfphl(h, l ,tf ,css, pdhl_style) =>

    var line hl = line.new(
       na
     , na
     , na
     , na
     , xloc      = xloc.bar_time
     , color     = css
     , style     = lstyle(pdhl_style)
     )

    var line ll   = line.new(
       na
     , na
     , na
     , na
     , xloc      = xloc.bar_time
     , color     = css
     , style     = lstyle(pdhl_style)
     )

    var label lbl = label.new(
       na
     , na
     , xloc      = xloc.bar_time
     , text      = str.format('P{0}L', tf)
     , color     = invcol
     , textcolor = css
     , size      = size.small
     , style     = label.style_label_left
     )

    var label hlb = label.new(
       na
     , na
     , xloc      = xloc.bar_time
     , text      = str.format('P{0}H', tf)
     , color     = invcol
     , textcolor = css
     , size      = size.small
     , style     = label.style_label_left
     )

    hy = ta.valuewhen(h != h[1] , h    , 1)
    hx = ta.valuewhen(h == high , time , 1)
    ly = ta.valuewhen(l != l[1] , l    , 1)
    lx = ta.valuewhen(l == low  , time , 1)

    if barstate.islast

        extension = time + (time - time[1]) * 50
    
        line.set_xy1(hl , hx        , hy)
        line.set_xy2(hl , extension , hy)
        label.set_xy(hlb, extension , hy)
        line.set_xy1(ll , lx        , ly)
        line.set_xy2(ll , extension , ly)
        label.set_xy(lbl, extension , ly)

if lvl_daily

    mtfphl(pdh   , pdl , 'D'  , css_d, s_d)

if lvl_weekly

    mtfphl(pwh   , pwl , 'W'  , css_w, s_w)

if lvl_monthly

    mtfphl(pmh   , pml,  'M'  , css_m, s_m)

if lvl_yearly

    mtfphl(pyh   , pyl , '12M', css_y, s_y)
    

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - Market Structure                                                                                                                           }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

method darkcss(color css, float factor, bool bull) =>

    blue  = color.b(css) * (1 - factor)
    red   = color.r(css) * (1 - factor)
    green = color.g(css) * (1 - factor)

    color.rgb(red, green, blue, 0)

method f_line(msDraw d, size, style) =>

    var line  id  = na
    var label lbl = na

    id := line.new(
       d.n
     , d.p
     , b.n
     , d.p
     , color = d.css
     , width = 1
     , style = style
     )

    if msline.size() >= 250

        line.delete(msline.shift())

    msline.push(id)

    lbl := label.new(
       int(math.avg(d.n, b.n))
     , d.p
     , d.txt
     , color            = invcol
     , textcolor        = d.css
     , style            = d.bull ? label.style_label_down : label.style_label_up
     , size             = size
     , text_font_family = font.family_monospace
     )

structure(bool mtf) =>

	msDraw drw     = na

    bool isdrw     = false
    bool isdrwS   = false

    var color css  = na
    var color icss = na

	var int itrend = 0
    var int  trend = 0

    bool bull_ob   = false
    bool bear_ob   = false

    bool s_bull_ob = false
    bool s_bear_ob = false

    n = bar_index
	
	var ms up = ms.new(
		   array.new<float>()
		 , array.new< int >()
         , array.new<float>()
		 )

	var ms dn = ms.new(
		   array.new<float>()
		 , array.new< int >()
         , array.new<float>()
		 )

	var ms sup = ms.new(
		   array.new<float>()
		 , array.new< int >()
         , array.new<float>()
		 )

	var ms sdn = ms.new(
		   array.new<float>()
		 , array.new< int >()
         , array.new<float>()
		 )

    switch show_swing_ms

        "All"      =>  boolean.set(s_BREAK , true ),  boolean.set(s_CHANGE, true ) , boolean.set(s_CHANGEP, true  )  
        "CHANGE"   =>  boolean.set(s_BREAK , false),  boolean.set(s_CHANGE, true ) , boolean.set(s_CHANGEP, false )   
        "CHANGE+"  =>  boolean.set(s_BREAK , false),  boolean.set(s_CHANGE, false) , boolean.set(s_CHANGEP, true  )  
        "BREAK"    =>  boolean.set(s_BREAK , true ),  boolean.set(s_CHANGE, false) , boolean.set(s_CHANGEP, false )  
        "None"     =>  boolean.set(s_BREAK , false),  boolean.set(s_CHANGE, false) , boolean.set(s_CHANGEP, false )  
        => na

    switch show_internal_ms

        "All"      =>  boolean.set(i_BREAK, true ),  boolean.set(i_CHANGE, true  ),  boolean.set(i_CHANGEP, true )
        "CHANGE"   =>  boolean.set(i_BREAK, false),  boolean.set(i_CHANGE, true  ),  boolean.set(i_CHANGEP, false) 
        "CHANGE+"  =>  boolean.set(i_BREAK, false),  boolean.set(i_CHANGE, false ),  boolean.set(i_CHANGEP, true ) 
        "BREAK"    =>  boolean.set(i_BREAK, true ),  boolean.set(i_CHANGE, false ),  boolean.set(i_CHANGEP, false) 
        "None"     =>  boolean.set(i_BREAK, false),  boolean.set(i_CHANGE, false ),  boolean.set(i_CHANGEP, false) 
        => na
        
    switch
        iH =>

            up.p.unshift(b.h[iLen])
            up.l.unshift(b.h[iLen])
            up.n.unshift(n  [iLen])

        iL =>

            dn.p.unshift(b.l[iLen])
            dn.l.unshift(b.l[iLen])
            dn.n.unshift(n  [iLen])

        sL =>

            sdn.p.unshift(b.l[sLen])
            sdn.l.unshift(b.l[sLen])
            sdn.n.unshift(n  [sLen])

        sH =>

            sup.p.unshift(b.h[sLen])
            sup.l.unshift(b.h[sLen])
            sup.n.unshift(n  [sLen])

	// INTERNAL BULLISH STRUCTURE
	if up.p.size() > 0 and dn.l.size() > 1

		if ta.crossover(b.c, up.p.first())

			bool CHANGE = na
			string txt = na

			if itrend < 0

				CHANGE := true

			switch

				not CHANGE =>

					txt := "BREAK"
					css := i_ms_up_BREAK

                    blalert.bos := true

					if boolean.get(i_BREAK) and mtf == false and na(drw)

                        isdrw := true
						drw := msDraw.new(
							   up.n.first()
							 , up.p.first()
							 , i_ms_up_BREAK
							 , txt
							 , true
							 )	

				CHANGE => 

                    dn.l.first() > dn.l.get(1) ? blalert.chochplus : blalert.choch

					txt := dn.l.first() > dn.l.get(1) ? "CHANGE+" : "CHANGE"
					css := i_ms_up_BREAK.darkcss(0.25, true)

					if (dn.l.first() > dn.l.get(1) ? boolean.get(i_CHANGEP) : boolean.get(i_CHANGE)) and mtf == false and na(drw)

                        isdrw := true
						drw := msDraw.new(
							   up.n.first()
							 , up.p.first()
							 , i_ms_up_BREAK.darkcss(0.25, true)
							 , txt
							 , true
							 )				

			if mtf == false

				switch

					ob_filter == "None" 					    => bull_ob := true
					ob_filter == "BREAK"    and txt == "BREAK"  => bull_ob := true
					ob_filter == "CHANGE"  and txt == "CHANGE"  => bull_ob := true
					ob_filter == "CHANGE+" and txt == "CHANGE+" => bull_ob := true

			itrend := 1
            up.n.clear()
            up.p.clear()

	// INTERNAL BEARISH STRUCTURE
	if dn.p.size() > 0 and up.l.size() > 1

		if ta.crossunder(b.c, dn.p.first())
            
			bool CHANGE = na
			string txt = na

			if itrend > 0

				CHANGE := true

			switch

				not CHANGE =>

                    bralert.bos := true

					txt := "BREAK"
					css := i_ms_dn_BREAK

					if boolean.get(i_BREAK) and mtf == false and na(drw)

                        isdrw := true
						drw := msDraw.new(
							   dn.n.first()
							 , dn.p.first()
							 , i_ms_dn_BREAK
							 , txt
							 , false
							 )	

				CHANGE => 

                    if up.l.first() < up.l.get(1)
                        bralert.chochplus := true
                    else 
                        bralert.choch := true

					txt := up.l.first() < up.l.get(1) ? "CHANGE+" : "CHANGE"
					css := i_ms_dn_BREAK.darkcss(0.25, false)

					if (up.l.first() < up.l.get(1) ? boolean.get(i_CHANGEP) : boolean.get(i_CHANGE)) and mtf == false and na(drw)

                        isdrw := true
						drw := msDraw.new(
							   dn.n.first()
							 , dn.p.first()
							 , i_ms_dn_BREAK.darkcss(0.25, false)
							 , txt
							 , false
							 )			

			if mtf == false

				switch

					ob_filter == "None" 					    => bear_ob := true
					ob_filter == "BREAK"   and txt == "BREAK"   => bear_ob := true
					ob_filter == "CHANGE"  and txt == "CHANGE"  => bear_ob := true
					ob_filter == "CHANGE+" and txt == "CHANGE+" => bear_ob := true

			itrend := -1
            dn.n.clear()
            dn.p.clear()

	// SWING BULLISH STRUCTURE
	if sup.p.size() > 0 and sdn.l.size() > 1

		if ta.crossover(b.c, sup.p.first())

			bool CHANGE = na
			string txt = na

			if trend < 0

				CHANGE := true

			switch

				not CHANGE =>

                    blalert.swingbos := true

					txt := "BREAK"
					icss := s_ms_up_BREAK

					if boolean.get(s_BREAK) and mtf == false and na(drw)

                        isdrwS := true
						drw := msDraw.new(
							   sup.n.first()
							 , sup.p.first()
							 , s_ms_up_BREAK
							 , txt
							 , true
							 )	

				CHANGE => 

                    if sdn.l.first() > sdn.l.get(1)
                        blalert.chochplusswing := true
                    else 
                        blalert.chochswing := true

					txt := sdn.l.first() > sdn.l.get(1) ? "CHANGE+" : "CHANGE"
					icss := s_ms_up_BREAK.darkcss(0.25, true)

					if (sdn.l.first() > sdn.l.get(1) ? boolean.get(s_CHANGEP) : boolean.get(s_CHANGE)) and mtf == false and na(drw)

                        isdrwS := true
						drw := msDraw.new(
							   sup.n.first()
							 , sup.p.first()
							 , s_ms_up_BREAK.darkcss(0.25, true)
							 , txt
							 , true
							 )	

			if mtf == false

				switch
                
					ob_filter == "None" 					    => s_bull_ob := true
					ob_filter == "BREAK"   and txt == "BREAK"   => s_bull_ob := true
					ob_filter == "CHANGE"  and txt == "CHANGE"  => s_bull_ob := true
					ob_filter == "CHANGE+" and txt == "CHANGE+" => s_bull_ob := true

			trend := 1
            sup.n.clear()
            sup.p.clear()

	// SWING BEARISH STRUCTURE
	if sdn.p.size() > 0 and sup.l.size() > 1

		if ta.crossunder(b.c, sdn.p.first())

			bool CHANGE = na
			string txt = na

			if trend > 0

				CHANGE := true

			switch

				not CHANGE =>

                    bralert.swingbos := true

					txt := "BREAK"
					icss := s_ms_dn_BREAK

					if boolean.get(s_BREAK) and mtf == false and na(drw)

                        isdrwS := true
						drw := msDraw.new(
							   sdn.n.first()
							 , sdn.p.first()
							 , s_ms_dn_BREAK
							 , txt
							 , false
							 )	

				CHANGE => 

                    if sup.l.first() < sup.l.get(1)
                        bralert.chochplusswing := true
                    else
                        bralert.chochswing := true

					txt := sup.l.first() < sup.l.get(1) ? "CHANGE+" : "CHANGE"
					icss := s_ms_dn_BREAK.darkcss(0.25, false)

					if (sup.l.first() < sup.l.get(1) ? boolean.get(s_CHANGEP) : boolean.get(s_CHANGE)) and mtf == false and na(drw)

                        isdrwS := true
						drw := msDraw.new(
							   sdn.n.first()
							 , sdn.p.first()
							 , s_ms_dn_BREAK.darkcss(0.25, false)
							 , txt
							 , false
							 )		

			if mtf == false

				switch

					ob_filter == "None" 					     => s_bear_ob := true
					ob_filter == "BREAK"    and txt == "BREAK"   => s_bear_ob := true
					ob_filter == "CHANGE"   and txt == "CHANGE"  => s_bear_ob := true
					ob_filter == "CHANGE+"  and txt == "CHANGE+" => s_bear_ob := true

			trend := -1
            sdn.n.clear()
            sdn.p.clear()

    [css, bear_ob, bull_ob, itrend, drw, isdrw, s_bear_ob, s_bull_ob, trend, icss, isdrwS]


[css, bear_ob, bull_ob, itrend, drw, isdrw, s_bear_ob, s_bull_ob, trend, icss, isdrwS] = structure(false)

if isdrw
    f_line(drw, size.small, line.style_dashed)

if isdrwS
    f_line(drw, size.small, line.style_solid)

[_, _, _, itrend15, _, _, _, _, _, _, _] = request.security("", "15"    , structure(true))
[_, _, _, itrend1H, _, _, _, _, _, _, _] = request.security("", "60"    , structure(true))
[_, _, _, itrend4H, _, _, _, _, _, _, _] = request.security("", "240"   , structure(true))
[_, _, _, itrend1D, _, _, _, _, _, _, _] = request.security("", "1440"  , structure(true))

if show_mtf_str

    var tab = table.new(position = position.top_right, columns = 10, rows = 10, bgcolor = na, frame_color = color.rgb(54, 58, 69, 0), frame_width = 1, border_color = color.rgb(54, 58, 69, 100), border_width = 1)
    table.cell(tab, 0, 1, text = "15" , text_color = color.silver, text_halign = text.align_center, text_size = size.normal, bgcolor = chart.bg_color, text_font_family = font.family_monospace, width = 2)
    table.cell(tab, 0, 2, text = "1H"  , text_color = color.silver, text_halign = text.align_center, text_size = size.normal, bgcolor = chart.bg_color, text_font_family = font.family_monospace, width = 2)
    table.cell(tab, 0, 3, text = "4H"  , text_color = color.silver, text_halign = text.align_center, text_size = size.normal, bgcolor = chart.bg_color, text_font_family = font.family_monospace, width = 2)
    table.cell(tab, 0, 4, text = "1D"  , text_color = color.silver, text_halign = text.align_center, text_size = size.normal, bgcolor = chart.bg_color, text_font_family = font.family_monospace, width = 2)

    table.cell(tab, 1, 1, text = itrend15 == 1 ? "BULLISH" : itrend15 == -1 ? "BEARISH" : na  , text_halign = text.align_center, text_size = size.normal, text_color = itrend15 == 1 ? i_ms_up_BREAK.darkcss(-0.25, true) : itrend15 == -1 ? i_ms_dn_BREAK.darkcss(0.25, false) : color.gray, bgcolor = chart.bg_color, text_font_family = font.family_monospace)
    table.cell(tab, 1, 2, text = itrend1H == 1 ? "BULLISH" : itrend1H == -1 ? "BEARISH" : na  , text_halign = text.align_center, text_size = size.normal, text_color = itrend1H == 1 ? i_ms_up_BREAK.darkcss(-0.25, true) : itrend1H == -1 ? i_ms_dn_BREAK.darkcss(0.25, false) : color.gray, bgcolor = chart.bg_color, text_font_family = font.family_monospace)
    table.cell(tab, 1, 3, text = itrend4H == 1 ? "BULLISH" : itrend4H == -1 ? "BEARISH" : na  , text_halign = text.align_center, text_size = size.normal, text_color = itrend4H == 1 ? i_ms_up_BREAK.darkcss(-0.25, true) : itrend4H == -1 ? i_ms_dn_BREAK.darkcss(0.25, false) : color.gray, bgcolor = chart.bg_color, text_font_family = font.family_monospace)
    table.cell(tab, 1, 4, text = itrend1D == 1 ? "BULLISH" : itrend1D == -1 ? "BEARISH" : na  , text_halign = text.align_center, text_size = size.normal, text_color = itrend1D == 1 ? i_ms_up_BREAK.darkcss(-0.25, true) : itrend1D == -1 ? i_ms_dn_BREAK.darkcss(0.25, false) : color.gray, bgcolor = chart.bg_color, text_font_family = font.family_monospace)

    table.cell(tab, 0, 5, text = "Detected Pattern", text_halign = text.align_center, text_size = size.normal, text_color = color.silver, bgcolor = chart.bg_color, text_font_family = font.family_monospace)
    table.cell(tab, 0, 6, text = p.found, text_halign = text.align_center, text_size = size.normal, text_color = na(p.bull) ? color.white : p.bull ? i_ms_up_BREAK.darkcss(-0.25, true) : p.bull == false ? i_ms_dn_BREAK.darkcss(0.25, false) : na, bgcolor = chart.bg_color, text_font_family = font.family_monospace)
    
    table.merge_cells(tab, 0, 5, 1, 5)
    table.merge_cells(tab, 0, 6, 1, 6)

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - Strong/Weak High/Low And Equilibrium                                                                                                       }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

var phl = Zphl.new(
   na
 , na
 , label.new(na , na , color = invcol , textcolor = i_ms_dn_BREAK , style = label.style_label_down , size = size.tiny , text = "")
 , label.new(na , na , color = invcol , textcolor = i_ms_up_BREAK , style = label.style_label_up   , size = size.tiny , text = "")
 , true
 , true
 , true
 , true
 , ""
 , ""
 , 0
 , 0
 , 0
 , 0
 , high
 , low
 , 0
 , 0
 , 0
 , 0
 , 0
 , 0
 )

zhl(len)=>    

    upper = ta.highest(len)
    lower = ta.lowest(len)

    var float out = 0
    out := b.h[len] > upper ? 0 : b.l[len] < lower ? 1 : out[1]

    top = out == 0 and out[1] != 0 ? b.h[len] : 0
    btm = out == 1 and out[1] != 1 ? b.l[len] : 0

    [top, btm]

[top , btm ] = zhl(sLen)
[itop, ibtm] = zhl(iLen)

upphl(trend) =>

    var label lbl = label.new(
       na
     , na
     , color     = invcol
     , textcolor = toplvl
     , style     = label.style_label_down
     , size      = size.small
     )

    if top

        phl.stopcross := true
        phl.txtup     := top > phl.topy ? "HH" : "HL"

        if show_lbl

            topl = label.new(
               b.n - swing_r_lookback
             , top
             , phl.txtup
             , color     = invcol
             , textcolor = toplvl
             , style     = label.style_label_down
             , size      = size.small
             )

        line.delete(phl.top[1])

        phl.top := line.new(
               b.n - sLen
             , top
             , b.n
             , top
             , color = toplvl)

        phl.topy      := top
        phl.topx      := b.n - sLen
        phl.tup       := top
        phl.tupx      := b.n - sLen

    if itop

        phl.itopcross := true
        phl.itopy     := itop
        phl.itopx     := b.n - iLen
    phl.tup           := math.max(high, phl.tup)
    phl.tupx          := phl.tup == high ? b.n : phl.tupx

    if barstate.islast 

        line.set_xy1(
               phl.top
             , phl.tupx
             , phl.tup
             )

        line.set_xy2(
               phl.top
             , b.n + 50
             , phl.tup
             )

        label.set_x(
               lbl
             , b.n + 50
             )

        label.set_y(
               lbl
             , phl.tup
             )

        dist = math.abs((phl.tup - close) / close) * 100
        label.set_text (lbl, trend < 0 ? "Strong High" + " (" + str.tostring(math.round(dist,0)) + "%)" : "Weak High" + " (" + str.tostring(math.round(dist,0)) + "%)")

dnphl(trend) =>

    var label lbl = label.new(
       na
     , na
     , color     = invcol
     , textcolor = btmlvl
     , style     = label.style_label_up
     , size      = size.small
     )

    if btm

        phl.sbottomcross := true
        phl.txtdn        := btm > phl.bottomy ? "LL" : "LH"

        if show_lbl

            btml = label.new(
               b.n - swing_r_lookback
             , btm, phl.txtdn
             , color = invcol
             , textcolor = btmlvl
             , style = label.style_label_up
             , size = size.small
             )

        line.delete(phl.bottom[1])
        
        phl.bottom := line.new(
           b.n - sLen
         , btm
         , b.n
         , btm
         , color = btmlvl
         )
        phl.bottomy      := btm
        phl.bottomx      := b.n - sLen
        phl.tdn          := btm
        phl.tdnx         := b.n - sLen

    if ibtm

        phl.ibottomcross := true
        phl.ibottomy     := ibtm
        phl.ibottomx     := b.n - iLen

    phl.tdn              := math.min(low, phl.tdn)
    phl.tdnx             := phl.tdn == low ? b.n : phl.tdnx

    if barstate.islast

        line.set_xy1(
           phl.bottom
         , phl.tdnx
         , phl.tdn
         )

        line.set_xy2(
           phl.bottom
         , b.n + 50
         , phl.tdn
         )

        label.set_x(
           lbl
         , b.n + 50
         )

        label.set_y(
           lbl
         , phl.tdn
         )
         
        dist = math.abs((phl.tdn - close) / close) * 100
        label.set_text (lbl, trend > 0 ? "Strong Low" + " (" + str.tostring(math.round(dist,0)) + "%)" : "Weak Low" + " (" + str.tostring(math.round(dist,0)) + "%)")

midphl() =>

    avg = math.avg(phl.bottom.get_y2(), phl.top.get_y2())
    
    var line l = line.new(
       y1 = avg
     , y2 = avg
     , x1 = b.n - sLen
     , x2 = b.n + 50
     , color = midlvl
     , style = line.style_solid
     )

    var label lbl = label.new(
       x = b.n + 50
     , y = avg
     , text = "Equilibrium"
     , style = label.style_label_left
     , color = invcol
     , textcolor = midlvl
     , size = size.small
     )
     
    if barstate.islast

        more = (phl.bottom.get_x1() + phl.bottom.get_x2()) > (phl.top.get_x1() + phl.top.get_x2()) ? phl.top.get_x1() : phl.bottom.get_x1()
        line.set_xy1(l   , more    , avg)
        line.set_xy2(l   , b.n + 50, avg)
        label.set_x (lbl , b.n + 50     )
        label.set_y (lbl , avg          )
        dist = math.abs((l.get_y2() - close) / close) * 100
        label.set_text (lbl, "Equilibrium (" + str.tostring(math.round(dist,0)) + "%)")     
          
hqlzone() =>

    if barstate.islast

        var dZone = hqlzone.new(
               box.new(left = int(math.max(phl.topx, phl.bottomx)), top = phl.tup                          , right = b.n + 50, bottom = 0.95  * phl.tup + 0.05  * phl.tdn , bgcolor = color.new(toplvl, 70), border_color = na)
             , box.new(left = int(math.max(phl.topx, phl.bottomx)), top = 0.535 * phl.tup + 0.465 * phl.tdn, right = b.n + 50, bottom = 0.535 * phl.tdn + 0.465 * phl.tup , bgcolor = color.new(midlvl, 70), border_color = na)
             , box.new(left = int(math.max(phl.topx, phl.bottomx)), top = 0.95  * phl.tdn + 0.05  * phl.tup, right = b.n + 50, bottom = phl.tdn                           , bgcolor = color.new(btmlvl, 70), border_color = na)

             , label.new(x = int(math.avg(math.max(phl.topx, phl.bottomx), int(b.n + 50))), y = phl.tup, text = "Premium" , color = invcol, textcolor = toplvl, style = label.style_label_down, size = size.small)
             , label.new(x = int(b.n + 50)                                                , y = math.avg(phl.tup, phl.tdn), text = "Equilibrium", color = invcol, textcolor = midlvl, style = label.style_label_left, size = size.small)
             , label.new(x = int(math.avg(math.max(phl.topx, phl.bottomx), int(b.n + 50))), y = phl.tdn, text = "Discount", color = invcol, textcolor = btmlvl, style = label.style_label_up, size = size.small)
             )

if show_mtb

    upphl (trend)
    dnphl (trend)
    hqlzone()

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - Volumetric Order Block                                                                                                                     }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}


method eB(box[] b, bool ext, color css) =>
    b.unshift(
         box.new(
               na
             , na
             , na
             , na
             , xloc             = xloc.bar_time
             , text_font_family = font.family_monospace
             , extend           = ext ? extend.right : extend.none
             , border_color     = color.new(color.white,100)
             , bgcolor          = css
              )
             )

method eL(line[] l, bool ext, bool solid, color css) =>
    l.unshift(
         line.new(
               na
             , na
             , na
             , na
             , width  = 1
             , color  = css
             , xloc   = xloc.bar_time
             , extend = ext   ? extend.right     : extend.none
             , style  = solid ? line.style_solid : line.style_dashed
              )
             )

method drawVOB(bool cdn, bool bull, color css, int loc) =>

    [cC, oO, hH, lL, vV] = request.security(
         syminfo.tickerid
         , ""

         ,   [

               close
             , open
             , high
             , low
             , volume

             ]

         , lookahead = barmerge.lookahead_off
                                           )
    var obC obj  = obC.new(
                   array.new<float>()
                 , array.new<float>()
                 , array.new< int >()
                 , array.new<float>()
                 , array.new<float>()
                 , array.new<float>()
                 , array.new< int >()
                 , array.new< int >()
                 , array.new< int >()
                 , array.new< int >()
                 , array.new<float>()
                 , array.new<float>()
                 , array.new< int >()
                 )

    var obD draw = obD.new(
                   array.new<box >()
                 , array.new<box >()
                 , array.new<box >()
                 , array.new<box >()
                 , array.new<line>()
                 )

    if barstate.isfirst

        for i = 0 to ob_num - 1

            draw.mL .eL(false, false, use_grayscale ? color.new(color.gray, 0) : color.new(css,0))
            draw.ob .eB(false, use_grayscale ? color.new(color.gray, 90) : css                   )
            draw.blB.eB(false, css_metric_up                                                       )
            draw.brB.eB(false, css_metric_dn                                                       )
            draw.eOB.eB(true , use_grayscale ? color.new(color.gray, 90) : css                   )


    if cdn

        obj.h.clear()
        obj.l.clear()
        obj.n.clear()

        for i = 1 to math.abs((loc - b.n))

            obj.h.unshift(hH[i])
            obj.l.unshift(lL[i])
            obj.n.unshift(b.t[i])

        int iU = obj.l.indexof(obj.l.min())
        int iD = obj.h.indexof(obj.h.max())

        obj.dir.unshift(
             bull 
                 ? (b.c[iU] > b.o[iU] ? 1 : -1) 
                 : (b.c[iD] > b.o[iD] ? 1 : -1)
             )

        obj.top.unshift(
             bull 
                 ? (
                     math.avg(
                         obj.h.max(), obj.l.min()) > obj.h.get(iU)
                             ? obj.h.get(iU)
                             : math.avg(obj.h.max(), obj.l.min())
                     )
                 : obj.h.max()
             )

        obj.btm.unshift(
             bull 
                 ? obj.l.min() 
                 : (
                     math.avg(
                         obj.h.max(), obj.l.min()) < obj.l.get(iD) 
                             ? obj.l.get(iD) 
                             : math.avg(obj.h.max(), obj.l.min())
                     )
             )

        obj.left.unshift(
             bull 
                 ? obj.n.get(obj.l.indexof(obj.l.min())) 
                 : obj.n.get(obj.h.indexof(obj.h.max()))
             )

        obj.avg.unshift(
             math.avg(obj.top.first(), obj.btm.first())
             )

        obj.cV.unshift(
             bull 
                 ? b.v[iU] 
                 : b.v[iD]
             )

        obj.blVP.unshift ( 0 )
        obj.brVP.unshift ( 0 )
        obj.wM  .unshift ( 1 )

        if use_overlap

            int rmP = use_overlap_method == "Recent" ? 1 : 0

            if obj.avg.size() > 1

                if bull 

                     ? obj.btm.first() < obj.top.get(1) 
                     : obj.top.first() > obj.btm.get(1)
                    obj.wM   .remove(rmP)
                    obj.cV   .remove(rmP)
                    obj.dir  .remove(rmP)
                    obj.top  .remove(rmP)
                    obj.avg  .remove(rmP) 
                    obj.btm  .remove(rmP)
                    obj.left .remove(rmP)
                    obj.blVP .remove(rmP)
                    obj.brVP .remove(rmP)

    if barstate.isconfirmed

        for x = 0 to ob_num - 1

            tg = switch ob_mitigation
                "Middle"   => obj.avg
                "Absolute" => bull ? obj.btm : obj.top

            for [idx, pt] in tg

                if (bull ? cC < pt : cC > pt)
                    obj.wM   .remove(idx)
                    obj.cV   .remove(idx)
                    obj.dir  .remove(idx)
                    obj.top  .remove(idx)
                    obj.avg  .remove(idx) 
                    obj.btm  .remove(idx)
                    obj.left .remove(idx)
                    obj.blVP .remove(idx)
                    obj.brVP .remove(idx)
            
    if barstate.islast

        if obj.avg.size() > 0

            float tV = 0
            obj.dV.clear()
            seq = math.min(ob_num - 1, obj.avg.size() - 1)

            for j = 0 to seq

                tV += obj.cV.get(j)

                if j == seq

                    for y = 0 to seq

                        obj.dV.unshift(
                             math.floor(
                                 (obj.cV.get(y) / tV) * 100)
                         )

            for i = 0 to math.min(ob_num - 1, obj.avg.size() - 1)

                dmL   = draw.mL .get(i)
                dOB   = draw.ob .get(i)
                dblB  = draw.blB.get(i)
                dbrB  = draw.brB.get(i)
                deOB  = draw.eOB.get(i)

                dOB.set_lefttop     (obj.left .get(i)           , obj.top.get(i))
                deOB.set_lefttop    (b.t                        , obj.top.get(i))
                dOB.set_rightbottom (b.t                        , obj.btm.get(i))
                deOB.set_rightbottom(b.t + (b.t - b.t[1]) * 100 , obj.btm.get(i))

                if use_middle_line

                    dmL.set_xy1(obj.left.get(i), obj.avg.get(i))
                    dmL.set_xy2(b.t            , obj.avg.get(i))

                if ob_metrics_show

                    dblB.set_lefttop    (obj.left.get(i), obj.top.get(i))
                    dbrB.set_lefttop    (obj.left.get(i), obj.avg.get(i))
                    dblB.set_rightbottom(obj.left.get(i), obj.avg.get(i))
                    dbrB.set_rightbottom(obj.left.get(i), obj.btm.get(i))

                    rpBL = dblB.get_right()
                    rpBR = dbrB.get_right()
                    dbrB.set_right(rpBR + (b.t - b.t[1]) * obj.brVP.get(i))
                    dblB.set_right(rpBL + (b.t - b.t[1]) * obj.blVP.get(i))

                if use_show_metric

                    txt = switch

                        obj.cV.get(i) >= 1000000000 => str.tostring(math.round(obj.cV.get(i) / 1000000000,3)) + "B"
                        obj.cV.get(i) >= 1000000    => str.tostring(math.round(obj.cV.get(i) / 1000000,3))    + "M"
                        obj.cV.get(i) >= 1000       => str.tostring(math.round(obj.cV.get(i) / 1000,3))       + "K"
                        obj.cV.get(i) <  1000       => str.tostring(math.round(obj.cV.get(i)))

                    deOB.set_text(
                         str.tostring(
                         txt + " (" + str.tostring(obj.dV.get(i)) + "%)")
                         )

                    deOB.set_text_size  (size.auto)
                    deOB.set_text_halign(text.align_left)
                    deOB.set_text_color (use_grayscale ? color.silver : color.new(css, 0))

    if ob_metrics_show and barstate.isconfirmed

        if obj.wM.size() > 0
            
            for i = 0 to obj.avg.size() - 1

                switch obj.dir.get(i)

                    1  =>

                        switch obj.wM.get(i)

                            1 => obj.blVP.set(i, obj.blVP.get(i) + 1), obj.wM.set(i, 2)
                            2 => obj.blVP.set(i, obj.blVP.get(i) + 1), obj.wM.set(i, 3)
                            3 => obj.brVP.set(i, obj.brVP.get(i) + 1), obj.wM.set(i, 1)
                    -1 =>

                        switch obj.wM.get(i)

                            1 => obj.brVP.set(i, obj.brVP.get(i) + 1), obj.wM.set(i, 2)
                            2 => obj.brVP.set(i, obj.brVP.get(i) + 1), obj.wM.set(i, 3)
                            3 => obj.blVP.set(i, obj.blVP.get(i) + 1), obj.wM.set(i, 1)

var hN = array.new<int>(1, b.n)
var lN = array.new<int>(1, b.n)
var hS = array.new<int>(1, b.n)
var lS = array.new<int>(1, b.n)

if iH

    hN.pop()
    hN.unshift(int(b.n[iLen]))

if iL

    lN.pop()
    lN.unshift(int(b.n[iLen]))

if sH

    hS.pop()
    hS.unshift(int(b.n[sLen]))

if sL

    lS.pop()
    lS.unshift(int(b.n[sLen]))

if ob_show

    bull_ob.drawVOB(true , ob_bull_css, hN.first())
    bear_ob.drawVOB(false, ob_bear_css, lN.first())


if ob_swings

    s_bull_ob.drawVOB(true , css_swing_up, hS.first())
    s_bear_ob.drawVOB(false, css_swing_dn, lS.first())

if bull_ob
    blalert.ob := true

if bear_ob
    bralert.ob := true

if s_bull_ob
    blalert.swingob := true

if s_bear_ob
    blalert.swingob := true

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}


































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - FVG | VI | OG                                                                                                                              }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

ghl() => request.security(syminfo.tickerid, fvg_tf, [high[2], low[2], close[1], open[1]])
tfG() => request.security(syminfo.tickerid, fvg_tf, [open, high, low, close])

cG(bool bull) =>

    [h, l, c, o]     = ghl()
    [go, gh, gl, gc] = tfG()

    var FVG draw   = FVG.new(
           array.new<box>()
         , array.new<line>()
         )

    var FVG[] cords = array.new<FVG>()

    float pup = na
    float pdn = na
    bool  cdn = na
    int   pos = 2
    change_tf = timeframe.change(fvg_tf)

    if barstate.isfirst

        for i = 0 to fvg_num - 1

            draw.box.unshift(box.new (na, na, na, na, border_color = color.new(color.white, 100), xloc = xloc.bar_time))
            draw.ln.unshift (line.new(na, na, na, na, xloc = xloc.bar_time, width = 1, style = line.style_solid))

    switch what_fvg

        "FVG" => 

            pup := bull ?     gl : l
            pdn := bull ?      h : gh
            cdn := bull ? gl > h and change_tf : gh < l and change_tf
            pos := 2

        "VI" =>

            pup := bull 
                 ? (gc > go 
                  ? go 
                   : gc) 
                 : (gc[1] > go[1] 
                  ? go[1] 
                   : gc[1])
            pdn := bull 
                 ? (gc[1] > go[1] 
                  ? gc[1] 
                   : go[1]) 
                 : (gc > go 
                  ? gc 
                   : go)
            cdn := bull 
                 ? go > gc[1] and gh[1] > gl and gc > gc[1] and go > go[1] and gh[1]  < math.min(gc, go) and change_tf
                 : go < gc[1] and gl[1] < gh and gc < gc[1] and go < go[1] and gl[1]  > math.max(gc, go) and change_tf
            pos := 1

        "OG" =>

            pup := bull ?        b.l : gl[1]
            pdn := bull ?      gh[1] : gh
            cdn := bull ? gl > gh[1] and change_tf : gh < gl[1] and change_tf
            pos := 1       

    if not na(cdn) and cdn

        cords.unshift(
             FVG.new(
               na
             , na
             , bull 
              ? true 
              : false 
             , pup 
             , pdn
             , b.t - (b.t - b.t[1]) * pos
             , b.t + (b.t - b.t[1]) * fvg_extend)
             )
            
        if bull
            blalert.fvg := true
        else
            bralert.fvg := true
    
    if barstate.isconfirmed

        for [idx, obj] in cords

            if obj.bull ? b.c < obj.btm : b.c > obj.top

                cords.remove(idx)
        
    if barstate.islast

        if cords.size() > 0

            for i = math.min(fvg_num - 1, cords.size() - 1) to 0

                gbx = draw.box.get(i)
                gln = draw.ln.get(i)
                gcd = cords.get(i)
                
                gtop   = gcd.top
                gbtm   = gcd.btm
                left  = gcd.left
                right = gcd.right

                gbx.set_lefttop(left, gtop)
                gbx.set_rightbottom(right, gbtm)
                gbx.set_bgcolor(gcd.bull ? fvg_upcss : fvg_dncss)

                gln.set_xy1(left, math.avg(gbx.get_top(), gbx.get_bottom()))
                gln.set_xy2(right, math.avg(gbx.get_top(), gbx.get_bottom()))
                gln.set_color(gcd.bull ? fvg_upcss : fvg_dncss)

if fvg_enable       

    cG(true )
    cG(false)

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - END                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}


































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - Accumulation And Distribution                                                                                                              }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

drawZone(int len) =>
    var zone[]  z = array.new<zone>()

    if iH

        z.unshift(
             zone.new(
                 chart.point.from_time(
                       time[len]
                     , high[len]
                     )
                     , high[len]
                     ,  1
                     , time[len]
                 )
             )
    if iL
        z.unshift(
             zone.new(
                 chart.point.from_time(
                       time[len]
                     , low [len]
                     )
                     , low [len]
                     , -1
                     , time[len]
                 )
             )
    if z.size() > 1
        if z.get(0).c == z.get(1).c
            z.clear()
    
    switch

        zone_mode == "Slow" =>

            if z.size() > 5

                if z.get(0).c == -1 and z.get(1).c == 1 and z.get(2).c == -1 and z.get(3).c == 1 and z.get(4).c == -1 and z.get(5).c == 1

                    if z.get(0).p > z.get(2).p and z.get(2).p > z.get(4).p

                        if z.get(1).p < z.get(3).p and z.get(3).p < z.get(5).p   

                            blalert.zone := true

                            box.new(top = z.get(5).p, bottom = z.get(4).p, left = z.get(5).t, right = z.get(0).t, bgcolor = acc_css, border_color = color.new(color.white, 100), xloc = xloc.bar_time)
                            slice = array.new<chart.point>()

                            for i = 0 to 5

                                slice.unshift(z.get(i).points)

                            polyline.new(slice, xloc = xloc.bar_time, line_color = color.new(acc_css, 0), line_width = 2)
                            p.found := "Accumulation Zone"
                            p.bull := true
                            p.isfound := true
                            p.period := 0
                            z.clear()

            if z.size() > 5

                if z.get(0).c == 1 and z.get(1).c == -1 and z.get(2).c == 1 and z.get(3).c == -1 and z.get(4).c == 1 and z.get(5).c == -1

                    if z.get(0).p < z.get(2).p and z.get(2).p < z.get(4).p

                        if z.get(1).p > z.get(3).p and z.get(3).p > z.get(5).p    

                            bralert.zone := true

                            box.new(top = z.get(4).p, bottom = z.get(5).p, left = z.get(5).t, right = z.get(0).t, bgcolor = dist_css, border_color = color.new(color.white, 100), xloc = xloc.bar_time)
                            slice = array.new<chart.point>()

                            for i = 0 to 5

                                slice.unshift(z.get(i).points)

                            polyline.new(slice, xloc = xloc.bar_time, line_color = color.new(dist_css, 0), line_width = 2)
                            p.found := "Distribution Zone"
                            p.bull := false
                            p.isfound := true
                            p.period := 0
                            z.clear()   

        zone_mode == "Fast" =>    

            if z.size() > 3

                if z.get(0).c == -1 and z.get(1).c == 1 and z.get(2).c == -1 and z.get(3).c == 1

                    if z.get(0).p > z.get(2).p

                        if z.get(1).p < z.get(3).p   

                            blalert.zone := true

                            box.new(top = z.get(3).p, bottom = z.get(2).p, left = z.get(3).t, right = z.get(0).t, bgcolor = acc_css, border_color = color.new(color.white, 100), xloc = xloc.bar_time)
                            slice = array.new<chart.point>()

                            for i = 0 to 3

                                slice.unshift(z.get(i).points)

                            polyline.new(slice, xloc = xloc.bar_time, line_color = color.new(acc_css, 0), line_width = 2)
                            p.found := "Accumulation Zone"
                            p.bull := true
                            p.isfound := true
                            p.period := 0
                            z.clear()

            if z.size() > 3

                if z.get(0).c == 1 and z.get(1).c == -1 and z.get(2).c == 1 and z.get(3).c == -1

                    if z.get(0).p < z.get(2).p

                        if z.get(1).p > z.get(3).p  

                            bralert.zone := true

                            box.new(top = z.get(2).p, bottom = z.get(3).p, left = z.get(3).t, right = z.get(0).t, bgcolor = dist_css, border_color = color.new(color.white, 100), xloc = xloc.bar_time)
                            slice = array.new<chart.point>()

                            for i = 0 to 3

                                slice.unshift(z.get(i).points)

                            polyline.new(slice, xloc = xloc.bar_time, line_color = color.new(dist_css, 0), line_width = 2)
                            p.found := "Distribution Zone"
                            p.bull := false
                            p.isfound := true
                            p.period := 0
                            z.clear()   

if show_acc_dist_zone

    drawZone(iLen)

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - END                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}


































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - EQH / EQL                                                                                                                                  }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

dEHL() =>

    var ehl w = ehl.new(0, 0, 0, 0)
    top = ta.pivothigh(high, 1, 1)
    btm = ta.pivotlow(low  , 1, 1)
    atr = ta.atr(200)

    switch

        top =>

            mx = math.max(top, w.pt)
            mn = math.min(top, w.pt)

            switch

                mx < mn + atr * 0.1 =>

                    var aZ = array.new<line>()
                    var aL = array.new<label>()

                    if aZ.size() > 50

                        aZ.pop().delete()
                        aL.pop().delete()

                    aZ.unshift(line.new(w.t, w.pt, b.n - 1, top, color = i_ms_dn_BREAK, style = line.style_dotted))
                    aL.unshift(label.new(int(math.avg(b.n - 1, w.t)), top, "EQH", color = invcol, textcolor = i_ms_dn_BREAK, style = label.style_label_down, size = size.tiny))

                    bralert.equal := true

            w.pt := top
            w.t := b.n - 1

        btm =>

            mx = math.max(btm, w.pb)
            mn = math.min(btm, w.pb)

            switch

                mn > mx - atr * 0.1 =>

                    var aZ = array.new<line>()
                    var aL = array.new<label>()

                    if aZ.size() > 50

                        aZ.pop().delete()
                        aL.pop().delete()

                    aZ.unshift(line.new(w.b, w.pb, b.n - 1, btm, color = i_ms_up_BREAK, style = line.style_dotted))
                    aL.unshift(label.new(int(math.avg(b.n - 1, w.b)), btm, "EQL", color = invcol, textcolor = i_ms_up_BREAK, style = label.style_label_up, size = size.tiny))

                    blalert.equal := true

            w.pb := btm
            w.b := b.n - 1


if show_eql
    dEHL()

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - End                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}


































//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - Plotting And Coloring                                                                                                                      }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}

p_css = css
b_css = css
w_css = css

p_css := plotcandle_bool ? (css) : na
b_css := barcolor_bool   ? (css) : na
w_css := plotcandle_bool ? color.rgb(120, 123, 134, 50)           : na

plotcandle(open,high,low,close , color = p_css , wickcolor = w_css , bordercolor = p_css , editable = false)
barcolor(b_css, editable = false)

//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{ - END                                                                                                                                        }
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}
//{----------------------------------------------------------------------------------------------------------------------------------------------}


























alertcondition(blalert.bos           , "Bullish BOS", "Bullish BOS")
alertcondition(blalert.choch         , "Bullish CHOCH", "Bullish CHOCH")
alertcondition(blalert.chochplus     , "Bullish CHOCH+", "Bullish CHOCH+")
alertcondition(blalert.chochplusswing, "Bullish Swing CHOCH+", "Bullish Swing CHOCH+")
alertcondition(blalert.chochswing    , "Bullish Swing CHOCH", "Bullish CHOCH")
alertcondition(blalert.swingbos      , "Bullish Swing BOS", "Bullish Swing BOS")
alertcondition(blalert.equal         , "EQL", "EQL")
alertcondition(blalert.fvg           , "Bullish FVG", "Bullish FVG")
alertcondition(blalert.ob            , "Bullish Order Block", "Bullish Order Block")
alertcondition(blalert.swingob       , "Bullish Swing Order Block", "Bullish Swing Order Block")
alertcondition(blalert.zone          , "Accumulation Zone", "Accumulation Zone")

alertcondition(bralert.bos           , "Bearish BOS", "Bearish BOS")
alertcondition(bralert.choch         , "Bearish CHOCH", "Bearish CHOCH")
alertcondition(bralert.chochplus     , "Bearish CHOCH+", "Bearish CHOCH+")
alertcondition(bralert.chochplusswing, "Bearish Swing CHOCH+", "Bearish Swing CHOCH+")
alertcondition(bralert.chochswing    , "Bearish Swing CHOCH", "Bearish CHOCH")
alertcondition(bralert.swingbos      , "Bearish Swing BOS", "Bearish Swing BOS")
alertcondition(bralert.equal         , "EQH", "EQH")
alertcondition(bralert.fvg           , "Bearish FVG", "Bearish FVG")
alertcondition(bralert.ob            , "Bearish Order Block", "Bearish Order Block")
alertcondition(bralert.swingob       , "Bearish Swing Order Block", "Bearish Swing Order Block")
alertcondition(bralert.zone          , "Distribution Zone", "Distribution Zone")


if barstate.isfirst
    var table errorBox = table.new(position.bottom_right, 1, 1, bgcolor = color.new(#363a45, 100))
    table.cell(errorBox,  0,  0,  "© Stratify",   text_color = color.gray, text_halign = text.align_center, text_size = size.normal)
    
