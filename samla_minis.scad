layer = "1"; // ["1":bottom,"2":top]

tray20 = 0; // [0:8]
tray25 = 7; // [0:7]
tray32 = 0; // [0:6]
tray40 = 0; // [0:3]

makeLastSolid = false; // [false:"Edge not Tray Solid", true: "Edge not Tray Solid"]

clearance = 1.0;
insertBorderWidth = 2;
trayHollowHight = 20;
edgeTrayBorderWidth = 5;

/* [Hidden] */
width = 198;
depth = layer == "1" ? 147 : 155;
hight = 3;

borderHight = 5;
borderWidth = 2;
falloutStopHight = 2.5;

totalTrays = tray20 + tray25 + tray32 + tray40;
neededWidth = 2 + (tray20 * 20 + tray25 * 25 + tray32 * 32 + tray40 * 40) + totalTrays * (borderWidth + clearance);
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
                    translate([xpos + i * (trayDist + clearance + borderWidth) - (trayDist + clearance)/2, depth/2 + n * (y + insertBorderWidth), -1]) cube([x,y,10], center=true);
                    translate([xpos + i * (trayDist + clearance + borderWidth) - (trayDist + clearance)/2, depth/2 - n * (y + insertBorderWidth), -1]) cube([x,y,10], center=true);
                }
            }
        }
    }
}

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

        cube([width,edgeTrayBorderWidth,hight]);
        translate([0, depth-edgeTrayBorderWidth, 0]) cube([width,edgeTrayBorderWidth,hight]);
    }
}