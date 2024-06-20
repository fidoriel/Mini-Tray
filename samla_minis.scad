layer = "1"; // ["1":Samla bottom,"2":Samla top, "3":365 1Liter,"4":365 0.75Liter,"5":365 5.2Liter,"6":custom]

tray16 = 0; // [0:10]
tray20 = 0; // [0:8]
tray25 = 7; // [0:7]
tray28 = 0; // [0:6]
tray32 = 0; // [0:6]
tray40 = 0; // [0:4]
tray50 = 0; // [0:3]
tray60 = 0; // [0:4]
tray75 = 0; // [0:2]

makeLastSolid = false; // [false:"Edge not Tray Solid", true: "Edge not Tray Solid"]

clearance = 1.0;
insertBorderWidth = 2;
edgeTrayBorderWidth = 5;
clampHight = 5;

customWidth = 100;
customDepth = 100;

/* [Hidden] */
trayHollowHight = 20;
version = layer == "1" || layer == "2" ? "samla" : (layer == "6" ? "custom" : "365");
depthPreset = layer == "1" ? 147 : (
                layer == "2" ? 155 : (
                    layer == "5" ? 175 : (
                        124
                    )
                )
            )
;
hight = version == "samla" ? 3 : 5.2;
widthPreset = layer == "3" ? 183 : (
                layer == "4" ? 124 : (
                    layer == "5" ? 280 : (
                        198
                    )
                )
            )
;
diameter = 40;

depth = layer == "6" ? customDepth : depthPreset;
width = layer == "6" ? customWidth : widthPreset;


borderHight = clampHight;
borderWidth = 2;

customRoundEdges = false;
edgeDegree = 0.0;

totalTrays = tray20 + tray25 + tray28 + tray32 + tray40 + tray50 + tray16 + tray60 + tray75;
neededWidth = 2 + (tray20 * 20 + tray25 * 25 + tray28 * 28 + tray32 * 32 + tray40 * 40 + tray50 * 50 + tray16 * 16 + tray60 * 60 + tray75 * 75) + totalTrays * (borderWidth + clearance);
for (i=[0:0]) echo(i);
assert( width >= neededWidth, "there are too many trays");

module prismL(){
    hull() polyhedron(
        points=[
            [0,0,borderHight/2],
            [borderHight/2,0,0],
            [borderHight/2,0,borderHight/2],
            [0,depth,borderHight/2],
            [borderHight/2,depth,0],
            [borderHight/2,depth,borderHight/2]
            ],
        faces=[[0,1,2],[1,2,5,4],[1,0,3,4],[0,2,5,3],[3,4,5]]
    );
}

module prismR(){
    hull() polyhedron(
        points=[
            [0,0,borderHight/2],
            [0,0,0],
            [borderHight/2,0,borderHight/2],
            [0,depth,borderHight/2],
            [0,depth,0],
            [borderHight/2,depth,borderHight/2]
            ],
        faces=[[0,1,2],[1,2,5,4],[1,0,3,4],[0,2,5,3],[3,4,5]]
    );
}

module border()
{
    cube([borderWidth, depth, borderHight]);
}

module borders(trayDist, trays, xpos)
{
    if (trays > 0)
    {
        // trays
        for (i=[0:trays]) {
            translate([xpos+i*(trayDist+clearance+borderWidth), 0, hight]) border();
        }
        // trangles R
        for (i=[0:trays-1]) {
            translate([xpos+i*(trayDist+clearance+borderWidth)+borderWidth, 0, borderHight/2+hight]) prismR();
        }
        // trangles L
        for (i=[1:trays]) {
            translate([xpos+i*(trayDist+clearance+borderWidth)-borderHight/2, 0, borderHight/2+hight]) prismL();
        } 
    }
}

module pattern(trayDist, trays, xpos, trayNrFirstTray)
{
    // hollow
    if (trays > 0)
    {
        // trays
        border = borderWidth;
        //x = (trayDist-4)/2 * 2 / 3 * sqrt(3);
        z = 10;

        // border = 2;
        // x = trayDist-4;
        // y = depth - 4;
        // z = 10;
        // hollow
        // for (i=[1:trays]) {
        //     if ( trayNrFirstTray+i > 1 && trayNrFirstTray+i < totalTrays ) {
        //         translate([xpos+i*(trayDist+clearance+borderWidth)-x-border, depth/2-y/2, -1]) cube([x,y,z]);
        //     }
        // }
        
        x = trayDist-2*borderWidth;
        //y = trayDist-insertBorderWidth;
        y = trayHollowHight;

        for (i=[1:trays]) {
            if ( trayNrFirstTray+i > 1 && trayNrFirstTray+i < totalTrays || !makeLastSolid ) {
                //translate([xpos + i * (trayDist + clearance + borderWidth) - trayDist/2 - clearance/2, depth/2, -1]) rotate(30) cylinder(x, x, x, $fn=6);

                hexRow = ceil((depth-border)/y);
                for(n=[0:ceil(hexRow/2)])
                {
                    // translate([xpos + i * (trayDist + clearance + borderWidth) - trayDist/2 - clearance/2, depth/2 - n * (2 * x + 2) , -1]) rotate(30) cylinder(x, x, x, $fn=6);
                    // translate([xpos + i * (trayDist + clearance + borderWidth) - trayDist/2 - clearance/2, depth/2 + n * (2 * x + 2) , -1]) rotate(30) cylinder(x, x, x, $fn=6);
                    translate([xpos + i * (trayDist + clearance + borderWidth) - (trayDist + clearance)/2, depth/2 + n * (y + insertBorderWidth), -1]) cube([x,y,3*hight], center=true);
                    translate([xpos + i * (trayDist + clearance + borderWidth) - (trayDist + clearance)/2, depth/2 - n * (y + insertBorderWidth), -1]) cube([x,y,3*hight], center=true);
                }
            }
        }
    }
}

module tray()
{
    union()
    {
        // Pattern
        difference()
        {
            // Base
            cube([width, depth, hight]);

            // Pattern
            union()
            {
                xpos20 = (width - neededWidth) / 2.0;

                pattern(20, tray20, xpos20, 0);
                xpos25 = xpos20 + tray20 * (clearance+borderWidth+20);

                pattern(25, tray25, xpos25, tray20);
                xpos32 = xpos25 + tray25 * (clearance+borderWidth+25);

                pattern(32, tray32, xpos32, tray20+tray25);
                xpos40 = xpos32 + tray32 * (clearance+borderWidth+32);

                pattern(40, tray40, xpos40, tray20+tray25+tray32);
                xpos50 = xpos40 + tray40 * (clearance+borderWidth+40);
                
                pattern(50, tray50, xpos50, tray20+tray25+tray32+tray40);
                
                xpos60 = xpos50 + tray50 * (clearance+borderWidth+50);
                pattern(60, tray60, xpos60, tray20+tray25+tray32+tray40+tray50);
                
                xpos75 = xpos60 + tray60 * (clearance+borderWidth+60);
                
                pattern(75, tray75, xpos75, tray20+tray25+tray32+tray40+tray60);
                
                xpos16 = xpos75 + tray75 * (clearance+borderWidth+75);
                
                pattern(16, tray16, xpos16, tray20+tray25+tray32+tray40+tray50+tray75);
                xpos28 = xpos16 + tray16 * (clearance+borderWidth+16);

                pattern(28, tray28, xpos28, tray20+tray25+tray32+tray40+tray50+tray75+tray16);
            }
        }

        // Borders
        union()
        {
            xpos20 = (width - neededWidth) / 2.0;

            borders(20, tray20, xpos20);
            xpos25 = xpos20 + tray20 * (clearance+borderWidth+20);

            borders(25, tray25, xpos25);
            xpos32 = xpos25 + tray25 * (clearance+borderWidth+25);

            borders(32, tray32, xpos32);
            xpos40 = xpos32 + tray32 * (clearance+borderWidth+32);

            borders(40, tray40, xpos40);
            xpos50 = xpos40 + tray40 * (clearance+borderWidth+40);
            
            borders(50, tray50, xpos50);
            xpos75 = xpos50 + tray50 * (clearance+borderWidth+50);
            
            borders(75, tray75, xpos75);
            xpos16 = xpos75 + tray75 * (clearance+borderWidth+75);
            
            borders(16, tray16, xpos16);
            xpos28 = xpos16 + tray16 * (clearance+borderWidth+16);

            borders(28, tray28, xpos28);
            
            xpos60 = xpos28 + tray28 * (clearance+borderWidth+28);
            borders(60, tray60, xpos60);

            cube([width,edgeTrayBorderWidth,hight]);
            translate([0, depth-edgeTrayBorderWidth, 0]) cube([width,edgeTrayBorderWidth,hight]);
        }
    }
}

module discQuater(diameter, border, hight)
{
    intersection()
    {
        difference()
        {
            cylinder(d=diameter, h=hight, $fn=120);
            cylinder(d=diameter-border*2, h=hight, $fn=120);
        }
        cube([diameter/2, diameter/2, hight]);
    }
}





if (version == "samla" || version == "custom" && customRoundEdges == false)
{
    tray();
}

else if (version == "365" || version == "custom" && customRoundEdges == true)
{
    union()
    {
        intersection()
        {
            tray();
            minkowski()
            {
                cube([width-diameter, depth-diameter, hight]);
                translate([ diameter/2, diameter/2, 0 ]) cylinder(d=diameter, h=hight+borderHight, $fn=120, center=false);
            }
        }
        //back right
        translate([width-diameter/2, depth-diameter/2, 0]) discQuater(diameter, edgeTrayBorderWidth, hight);
        //front left
        translate([diameter/2, diameter/2, 0]) mirror([1, 1, 0]) discQuater(diameter, edgeTrayBorderWidth, hight);
        //front right
        translate([width-diameter/2, diameter/2, 0]) mirror([0, 1, 0])  discQuater(diameter, edgeTrayBorderWidth, hight);
        //back left
        translate([diameter/2, depth-diameter/2, 0]) mirror([1, 0, 0]) discQuater(diameter, edgeTrayBorderWidth, hight);
    }
}
