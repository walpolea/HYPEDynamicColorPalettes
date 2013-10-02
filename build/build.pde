
//Drawing Basics
HCanvas brushLayer;
HCanvas canvasLayer;
HCanvas previewLayer;
PGraphics saveGraphics;

int canvasWidth = 800; 	 //viewport width
int canvasHeight = 600;		 //viewport height
int saveScaleUp = 8;		 //multiplier for the high quality sized saved image, 800 * 8 = 6400, 600 * 8 = 4800 = 6400px x 4800px image
float saveScaleDown = 0.125; //multiplier to return to normal scale ( 1 / saveScaleUp )

String renderer = JAVA2D;
boolean dirty = false;

Boolean showBrushLayer = true;
Boolean showColorPalette = true;

//HUD
HCanvas hud;
HText hudtext;
Boolean showHUD = true;

//Visual Elements
HGridLayout grid;

ArrayList<String> images;
int curImage = 0;

ArrayList<HShape> svgs;
int curSVG = 0;

//Key-Based Modifiers
int anchorOffset = 0;
int opacity = 255;
float shapeScale = 5.1;
int numShapes = 10;

//Color stuff
HPixelColorist palette;
HColorPool colors;
int numColors = 10;
int colorRadius = 10;

Boolean lockPalette = false;

void setup(){
	
	initCanvas();
	initPalettes();
	initSVGs();
	initHUD();
	
}

void draw() {
	
	//When holding down left mouse button
	if (mousePressed && (mouseButton == LEFT)) {
		drawToCanvas();
		dirty = true;
	}

	//When the mouse is lifted (done drawing) and there are new objects to save down (dirty)
	if( !mousePressed && dirty ) {
		saveDown();
		dirty = false;
	}

	//clear the old grid
	clearBrushLayer();

	//should we generate a new set of colors?
	if( !lockPalette ) {
		generateColorPalette();
	}

	if( showBrushLayer ) {
		//draw a new grid
		renderGrid();
	}

	//clear the HUD
	clearHUD();
	//draw the hud?
	if( showHUD ) {
		renderHUD();
	}

	H.drawStage();
	
}

//creates a new color palette based on mouse position, radius, and palette
void generateColorPalette() {
	colors = new HColorPool();
	int c;

	for( int j = 0; j < numColors; j++ ) {
		c = getMouseColor( colorRadius );
		//this adds the color with dynamic opacity applied
		colors.add( ( c & 0x00FFFFFF ) + (opacity << 24) );
	}
}

//gets a random color around the mouse based on a dynamic radius
int getMouseColor( float radius ) {
	float x = random( mouseX-radius, mouseX+radius );
	float y = random( mouseY-radius, mouseY+radius );

	return palette.getColor( x, y );
}



void renderGrid() {

	grid = new HGridLayout().cols( (int)sqrt(numShapes*14) ).spacing( 15*shapeScale, 15*shapeScale );

	for( int i = 0; i < numShapes*10; i++ ) {
		HShape s;
		//make a copy
		s = svgs.get(curSVG).createCopy();
		//use apply props to change anything about the HDrawable you want
		applyProps(s);
		//apply the colors from the color palette
		s.randomColors( colors );
		//add grid layout to the shape
		grid.applyTo(s);
		//and add to the brush layer so we can see it
		brushLayer.add( s );
	}
}

//you can do a whole lot of things here to each HDrawable
void applyProps( HDrawable d ) {
	d
		.anchor( d.width()*0.5 + anchorOffset, d.height()*0.5 + anchorOffset )
		.size( shapeScale*15 )
	;
}

/************
KEY Commands
*************
= & -, increase & decrease number of shapes in the grid
y & t, increase & decrease number of colors in palette
i & u, increase & decrease color picking radius
p & o, increase & decrease anchor offset of shapes
up & down, increase & decrease shape size
left & right, increase & decrease opacity of colors
[ & ] cycle through svgs
; & ' cycle  through color palette images

h, toggle HUD
j, toggle showing the brush layer (hide to see your art)
k, toggle showing color palette
l, toggle color palette lock (unlock to pick new colors, lock to set colors)

c, clear the background
f, fill the background with mouse color
s, save the high quality image

*/

//when a key is held down
void keyPressed() {

	switch(key) {
		//Change number of shapes being rendered
		case '=':
			numShapes += 2;
			if( numShapes > 2000) {
				numShapes = 2000;
			}
		break;
		case '-':
			numShapes -= 2;
			if( numShapes < 0 ) {
				numShapes = 0;
			}
		break;

		//Change the number of colors
		case 'y':
			numColors += 1;
		break;
		case 't':
			numColors -= 1;
			if( numColors < 1 ) {
				numColors = 1;
			}
		break;

		//Change the color picking radius
		case 'i':
			colorRadius += 1;
		break;
		case 'u':
			colorRadius -= 1;
			if( colorRadius < 0 ) {
				colorRadius = 0;
			}
		break;

		//Change the anchor offset
		case 'p':
			anchorOffset += 1;
		break;
		case 'o':
			anchorOffset -= 1;
			if( anchorOffset < 0 ) {
				anchorOffset = 0;
			}
		break;
	}

	switch(keyCode) {
		//Change Scale
	    case UP:
			shapeScale+=0.05;
	    break;
	    case DOWN:
			shapeScale-=0.05;
			if( shapeScale < 0 ) {
				shapeScale = 0;
			}
	    break;
	    //Change Opacity
	    case RIGHT:
	      	opacity+=4;
			if( opacity > 255) {
				opacity = 255;
			}
	    break;
	    case LEFT:
	     	opacity-=4;
			if( opacity < 0 ) {
				opacity = 0;
			}
	    break;
	}
}

//when a key is released
void keyReleased() {

	switch(key) {

		//Save the pretty picture!
		case 's':
			Date d = new Date();
			long timestamp = d.getTime();
			//Save the image file, this may take 5-10 seconds
			saveDown();
			saveGraphics.save( savePath("output/"+timestamp+"_highres.png") );
		break;

		//Cycle the SVG we are using in the grid
		case ']':
			curSVG++;
			if( curSVG >= svgs.size() ) {
				curSVG = 0;
			}
		break;
		case '[':
			curSVG--;
			if( curSVG < 0 ) {
				curSVG = svgs.size()-1;
			}
		break;

		//Clear the background (totally transparent)
		case 'c':
			clearCanvas();
			previewLayer.graphics().background(255, 0);
			saveGraphics.background(255, 0);
		break;

		//Fill the background with the color under the mouse
		case 'f':
			previewLayer.graphics().background( getMouseColor(0), 255);
			saveGraphics.background( getMouseColor(0), 255);
		break;

		//toggle hud
		case 'h':
			showHUD = !showHUD;
		break;

		//toggle showing the brush layer
		case 'j':
			showBrushLayer = !showBrushLayer;
		break;

		//toggle showing the color palette
		case 'k':
			showColorPalette = !showColorPalette;
		break;

		//toggle locking colors
		case 'l':
			lockPalette = !lockPalette;
		break;

		//cycle color palette image
		case '\'':
			curImage++;
			if( curImage >= images.size() ) {
				curImage = 0;
			}
			loadPalette();
		break;
		case ';':
			curImage--;
			if( curImage < 0 ) {
				curImage = images.size()-1;
			}
			loadPalette();
		break;

	}
}

//Draws things from the brushLayer to the canvasLayer
void drawToCanvas() {

	//if it's an HShape you can do extra things, so check
	if( brushLayer.firstChild() instanceof HShape ) {

		HShape child = (HShape)brushLayer.firstChild();

		while(child != null) {
			HShape c2 = child.createCopy();
			//one thing/bug I found is that createCopy() on an HShape
			//does not copy the colors, so you have to apply new ones when drawing
			//kinda sucks...
			c2.randomColors( colors );
			
			canvasLayer.add( c2 );
			child = (HShape)child.next();
		}

	} else {

		HDrawable child = brushLayer.firstChild();

		while(child != null) {
			HDrawable c2 = child.createCopy();
			canvasLayer.add( c2 );
			child = child.next();
		}
	}
}

void saveDown() {
	//paint the viewport pixels
	canvasLayer.paintAll( previewLayer.graphics(), false, 1 );

	//scale up and paint the high quality graphic to pixels
	canvasLayer.scale( saveScaleUp );
	canvasLayer.paintAll( saveGraphics, false, 1 );
	canvasLayer.scale( saveScaleDown );

	//canvas no longer needs to retain it's current vector children, so clear it
	clearCanvas();
}

void clearCanvas() {
	//Clear out the canvas layer or else things will slow down with so many vector hogging up memory
	HDrawable child = canvasLayer.firstChild();
	HDrawable oldchild;
	while(child != null) {
		oldchild = child;
		child = child.next();
		canvasLayer.remove( oldchild );
	}
}

void clearBrushLayer() {
	HDrawable child = brushLayer.firstChild();
	HDrawable oldchild;
	while(child != null) {

		oldchild = child;
		child = child.next();
		brushLayer.remove( oldchild );
	}
}

void clearHUD() {
	HDrawable child = hud.firstChild();
	HDrawable oldchild;
	while(child != null) {

		oldchild = child;
		child = child.next();
		hud.remove( oldchild );
	}
}

///////////////////////////////////////////////////
//Initialize all the drawing Canvases
///////////////////////////////////////////////////
void initCanvas() {

	size(canvasWidth,canvasHeight,renderer);
	H.init(this).background(#000000);
	smooth();
	
	saveGraphics = createGraphics( canvasWidth*saveScaleUp, canvasHeight*saveScaleUp, renderer );
	saveGraphics.smooth();

	previewLayer = new HCanvas( canvasWidth, canvasHeight, renderer ).autoClear( false );
	H.add( previewLayer );

	canvasLayer = new HCanvas( canvasWidth, canvasHeight, renderer ).autoClear( true );
	canvasLayer.transformsChildren(true);
	canvasLayer.graphics().smooth();
	H.add(canvasLayer);

	brushLayer = new HCanvas( canvasWidth, canvasHeight, renderer ).autoClear(true);
	brushLayer.graphics().smooth();
	H.add(brushLayer);

}

///////////////////////////////////////////////////
//Palettes, SVG, HUD
///////////////////////////////////////////////////
void initPalettes() {
	images = new ArrayList<String>();
    images.add( "palettes/flower.jpg" );
    images.add( "palettes/towel.jpg" );
    images.add( "palettes/curtain.jpg" );

    loadPalette();
}

void loadPalette() {
	palette = new HPixelColorist( images.get(curImage) ).fillOnly();
}

void initSVGs() {
	svgs = new ArrayList<HShape>();
	svgs.add( new HShape("svgs/svg1.svg").enableStyle(false) );
	svgs.add( new HShape("svgs/svg2.svg").enableStyle(false) );
	svgs.add( new HShape("svgs/svg3.svg").enableStyle(false) );
}

void initHUD() {
	//HUD
	hud = new HCanvas( canvasWidth, canvasHeight, renderer ).autoClear(true);
	H.add(hud);
	hudtext = new HText( "", 16 );
}

void renderHUD() {

	hud.add(hudtext);
	
	hudtext.text(   "Settings:" + "\n" +
					"palette: " + images.get(curImage) + "\n" +
					"size: " + shapeScale + "\n" +
					"opacity: " + opacity  + "\n" +
					"anchor offset: " + anchorOffset + "\n" +
					"shape amount: " + numShapes + "\n" +
					"color radius: " + colorRadius + "\n" +
					"locked palette: " + lockPalette + "\n" +
					"show color palette: " + showColorPalette + "\n" +
					"show brush layer: " + showBrushLayer + "\n"
				);

	hudtext.fill( 255, 255 );

	if( showColorPalette ) {
		renderColorPalette();
	}
	
}

void renderColorPalette() {

	//show the color picking radius
	HRect m = new HRect();
	m.loc( mouseX, mouseY ).width(colorRadius*2).height(colorRadius*2).fill( 0,127 ).anchorAt(H.CENTER);

	hud.add(m);

	//I'll confess I had to alter HYPE.pde, HColorPool, line 12, from
	//private ArrayList<Integer> _colorList;
	//to
	//public ArrayList<Integer> _colorList;
	//in order to do this next bit...

	HText colortext = new HText( "", 10 );
	colortext.loc( 0, 310).fill( 255, 255 );

	String s = "";

	for( int i=0; i < colors._colorList.size(); i++ ) {
		
		s += (String)hex(colors._colorList.get(i)) + "\n";
		
		HRect r = new HRect();
		r.width(25).height(25).fill( colors._colorList.get(i) ).loc( i*25, 270 ).stroke(0, 255).strokeWeight(1);
		hud.add( r );
	}
	println(s);
	colortext.text( s );
	hud.add( colortext );

}