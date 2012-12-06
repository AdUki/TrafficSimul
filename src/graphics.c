#include <allegro5/allegro.h>
#include <allegro5/allegro_font.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_primitives.h>

#include "main.h"

const float FPS = 50;

int BAR_W = 200;
int SCREEN_W = 640;
int SCREEN_H = 480;
int CAR_WIDTH = 32;
int TRACKS_NUM = 1;
int TRACKS_BEGIN = 0;
int TRACKS_FINISH = 0;
int world_x = 0, world_y = 0;
bool PAUSE = 0;

unsigned *cars_num;
float *cars_col;


static void drawCar(float x, float y, float lenght, float speed)
{
	// if car is out of screen we dont draw it
	if (x + world_x + lenght < 0) return;
	if (x + world_x >  SCREEN_W) return;
	
	// draw a car
	al_draw_filled_rectangle(
		x + world_x, y, 
		x + lenght + world_x, y + CAR_WIDTH,
		al_map_rgb(255*(1 - speed), 255*speed, 0));
}

static int getCar(lua_State *L)
{
	// get car from Lua state
	float track = lua_tonumber(L, 1);
	float lenght = lua_tonumber(L, 2);
	float position = lua_tonumber(L, 3);
	float maxspeed = lua_tonumber(L, 4);
	float speed = lua_tonumber(L, 5);
	lua_pop(L, 5);
	
	// add lua to bar
	int n = ((BAR_W)*(position+lenght))/(TRACKS_FINISH-TRACKS_BEGIN);
	cars_num[n] += 1;
	cars_col[n] += speed/maxspeed;
	cars_col[n] /= 2;

	// draw car to screen
	drawCar(position,
			((float)SCREEN_H - (CAR_WIDTH*1.3)*TRACKS_NUM)/2
			+ 0.15*CAR_WIDTH + (CAR_WIDTH*1.3)*(track - 1),
			lenght, speed/maxspeed);

	return 0;
}

void drawTracks()
{
	int n; 
	float y = ((float)SCREEN_H - (CAR_WIDTH * 1.3) * TRACKS_NUM)/2;
	
	for (n = TRACKS_BEGIN-5; n <= TRACKS_FINISH; n += 400) {
		al_draw_filled_circle(
			n + world_x, y - 60, 10,
			al_map_rgb(255,255,0));
	}
	
	al_draw_filled_rectangle(0, y,
			SCREEN_W, y + 1.3*CAR_WIDTH*TRACKS_NUM,
			al_map_rgb(20,20,20));
		
	
	for(n = 0; n <= TRACKS_NUM; n++) {
		al_draw_line(
				(float)TRACKS_BEGIN + world_x, y,
				(float)TRACKS_FINISH + world_x, y,
				al_map_rgb(200,200,200	), 1);
		y += (float)(CAR_WIDTH * 1.3);
	}
	
	for (n = TRACKS_BEGIN-5; n <= TRACKS_FINISH; n += 400) {
		al_draw_filled_circle(
			n + world_x, y + 40, 10,
			al_map_rgb(255,255,0));
	}
}

void drawBar()
{
	int n;
	for (n = 0; n < BAR_W; n++) {
		al_draw_filled_rectangle(
			n*(SCREEN_W/BAR_W), 0,
			(n+1)*(SCREEN_W/BAR_W), cars_num[n]*(30/TRACKS_NUM),
			al_map_rgb(255*(1 - cars_col[n]), 255*cars_col[n], 0));
		
		cars_num[n] = 0;
		cars_col[n] = 1;
	}
	
	al_draw_filled_rectangle(0, SCREEN_H-30,
			SCREEN_W, SCREEN_H,
			al_map_rgb(0,0,70));
	
	al_draw_filled_rectangle(
		-((SCREEN_W*world_x)/(TRACKS_BEGIN + TRACKS_FINISH)),
		SCREEN_H-30,
		((SCREEN_W*(SCREEN_W - world_x))/(TRACKS_BEGIN + TRACKS_FINISH)), 
		SCREEN_H,
		al_map_rgb(0,0,195));
}

int execAlleg()
{
	// init variables from lua

		lua_getglobal(L, "Screen");
		SCREEN_W = getfield(L, "width");
		SCREEN_H = getfield(L, "height");
		lua_pop(L, 1);

		printf("screen height= %d width= %d\n", SCREEN_H, SCREEN_W);

		lua_getglobal(L, "Car");
		CAR_WIDTH = getfield(L, "width");
		lua_pop(L, 1);

		printf("car width= %d\n", CAR_WIDTH);

		lua_getglobal(L, "Track");
		TRACKS_NUM = getfield(L, "number");
		TRACKS_BEGIN = getfield(L, "begin");
		TRACKS_FINISH = getfield(L, "finish");
		lua_pop(L, 1);

		// register C function to Lua
		lua_pushcfunction(L, getCar);
		lua_setglobal(L, "sendCar");

	// end of lua intialization

	ALLEGRO_DISPLAY *display = NULL;
	ALLEGRO_EVENT_QUEUE *event_queue = NULL;
	ALLEGRO_TIMER *timer = NULL;
	ALLEGRO_BITMAP *world;
	
	bool doexit = false;
	bool redraw = true;
	bool KEY_LEFT = false, KEY_RIGHT = false;

	if(!al_init()) {
		fprintf(stderr, "failed to initialize allegro!\n");
		return -1;
	}

	if(!al_install_keyboard()) {
		fprintf(stderr, "failed to initialize the keyboard!\n");
		return -1;
	}
	
	if(!al_install_mouse()) {
      fprintf(stderr, "failed to initialize the mouse!\n");
      return -1;
   }

	timer = al_create_timer(1.0 / FPS);
	if(!timer) {
		fprintf(stderr, "failed to create timer!\n");
		return -1;
	}

	display = al_create_display(SCREEN_W, SCREEN_H);
	if(!display) {
		fprintf(stderr, "failed to create display!\n");
		al_destroy_timer(timer);
		return -1;
	}

	if (!al_init_primitives_addon()) {
		fprintf(stderr, "failed to init primitives addon!\n");
		al_destroy_timer(timer);
		return -1;
	}

	event_queue = al_create_event_queue();
	if(!event_queue) {
		fprintf(stderr, "failed to create event_queue!\n");
		al_destroy_display(display);
		al_destroy_timer(timer);
		return -1;
	}
	
	world = al_create_bitmap(SCREEN_W, SCREEN_H);
	if(!world) {
		fprintf(stderr, "failed to create world bitmap!\n");
		al_destroy_display(display);
		al_destroy_timer(timer);
		return -1;
	}
	
	cars_num = (unsigned*)malloc(BAR_W*sizeof(unsigned));
	cars_col = (float*)malloc(BAR_W*sizeof(float));
	int n;
	for (n = 0; n < BAR_W; n++) {
		cars_num[n] = 0;
		cars_col[n] = 1;
	}
	
 
	al_set_target_bitmap(world);
	al_clear_to_color(al_map_rgb(0, 0, 0));
	al_set_target_bitmap(al_get_backbuffer(display));

	al_register_event_source(event_queue, al_get_display_event_source(display));
	al_register_event_source(event_queue, al_get_timer_event_source(timer));
	al_register_event_source(event_queue, al_get_keyboard_event_source());
	al_register_event_source(event_queue, al_get_mouse_event_source());
	
	al_start_timer(timer);

	while(!doexit)
	{
		ALLEGRO_EVENT ev;
		al_wait_for_event(event_queue, &ev);

		if(ev.type == ALLEGRO_EVENT_TIMER && 
			al_is_event_queue_empty(event_queue) &&
			!PAUSE) {
		
			al_set_target_bitmap(world);
			al_clear_to_color(al_map_rgb(0,0,0));

			// your code here
			
			drawTracks();
			
			lua_getglobal(L, "simulate");
			lua_call(L,0,0);
			
			drawBar();
			// end of your code
			
		}
		else if(ev.type == ALLEGRO_EVENT_DISPLAY_CLOSE) {
			break;
		}
		else if(ev.type == ALLEGRO_EVENT_KEY_DOWN) {
			switch(ev.keyboard.keycode) {
				case ALLEGRO_KEY_LEFT: KEY_LEFT = true; break;
				case ALLEGRO_KEY_RIGHT: KEY_RIGHT = true; break;
				case ALLEGRO_KEY_P: PAUSE = (PAUSE) ? false : true; break;
			}
		}
		else if(ev.type == ALLEGRO_EVENT_KEY_UP) {
			switch(ev.keyboard.keycode) {
				case ALLEGRO_KEY_LEFT: KEY_LEFT = false; break;
				case ALLEGRO_KEY_RIGHT: KEY_RIGHT = false; break;
			}
		}
		else if(ev.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN) {
			world_x = ((SCREEN_W - TRACKS_BEGIN - TRACKS_FINISH)*ev.mouse.x)/SCREEN_W;
		}
		/*
		if (ev.type == ALLEGRO_EVENT_MOUSE_AXES || 
			ev.type == ALLEGRO_EVENT_MOUSE_ENTER_DISPLAY) {
			al_flush_event_queue(event_queue);
		}
		*/
		if (KEY_LEFT) {
			if (world_x + 20 <= 0) world_x += 20;
		}
		if (KEY_RIGHT) {
			if (world_x - 20 >= SCREEN_W - TRACKS_BEGIN - TRACKS_FINISH) world_x -= 20;
		}
		
		if (redraw) {
			al_set_target_bitmap(al_get_backbuffer(display));
			al_draw_bitmap(world, 0, 0, 0);
			al_flip_display();
		}
	}

	al_destroy_timer(timer);
	al_destroy_display(display);
	al_destroy_event_queue(event_queue);
	al_shutdown_primitives_addon();

	return 0;
}
