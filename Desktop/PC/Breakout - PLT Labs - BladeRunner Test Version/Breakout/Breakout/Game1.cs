using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;
using System.Timers;
//using Plantronics.Innovation.PLTLabsAPI;
using Plantronics.Innovation.PLTLabsAPI2;

/*******
 * 
 * Head Tracking Target Demo
 * 
 * A demo sample project created for Plantronics PLTLabs innovation blog.
 * 
 * This application shows the following:
 * 
 *   - A game program that integrates support for Plantronics innovation head tracking
 *     
 *   - Uses headtracking angles to guide a target sight (reticle) on the game screen
 *   
 * PRE-REQUISITES for building this demo app:
 *  - Plantronics Spokes 3.0 SDK - install PlantronicsSpokesSDKInstaller.exe
 *  - Microsoft Visual Studio 2010 - obtain from http://www.microsoft.com/visualstudio/eng/products/visual-studio-2010-express
 *  - Microsoft XNA Game Studio 4.0 - obtain from http://www.microsoft.com/en-gb/download/details.aspx?id=23714
 *  (Drawing a Sprite Tutorial: http://msdn.microsoft.com/en-us/library/bb194908.aspx)
 *
 * PRE-REQUISITES for testing this demo app: 
 *  - Current pre-release head-tracking headset with appropriate firmware pre-loaded
 * 
 * ADDITIONAL INTERIM PRE-REQUISITE
 *  - At the time of writing there is also an additional pre-requisite to access headtracking
 *  data on a PC app, this is as follows:
 *    - Head-tracking headset also requires pairing with iPhone running iOS6 as  well as the PC 
 *    via BT300 Dongle.
 *    - The iPhone must also be running the "PLT Sensor" application (If this is still a pre-requisite
 *    as this blog goes to press then please request PLTLabs to join the "TestFlight" program for 
 *    "PLT Sensor" app). This app is needed to "reflect" the headtracking data back to your app on the PC.
 *   
 * INSTRUCTIONS FOR USE
 * 
 *   - If you put headset on and look at center of the screen, after 2 second delay the
 *     head tracking and target sight will "auto-calibrate" to center of screen.
 *     
 *   - From that point on the target sight will track your head movements
 *   
 *   - If you take your headset off the target sight will stop tracking your movements
 *   and place itself back in center of screen
 *   
 *   - Note: F will toggle fullscreen. Escape to quit.
 * 
 * Lewis Collins, http://developer.plantronics.com/people/lcollins/
 * 
 * VERSION HISTORY:
 * ********************************************************************************
 * Version 1.0.0.3:
 * Date: 1st November 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Updated project to remove local copy of PLTLabsAPI.dll
 *     (user should obtain and deploy the DLL from single location on PDC)
 *
 * Version 1.0.0.2:
 * Date: 7th October 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Changing XNA Framework game profile from HiDef to Reach
 *     to allow it to work on more graphics hardware
 *
 * Version 1.0.0.1:
 * Date: 27th September 2013
 * Changed by: Lewis Collins
 * Changes:
 *   - Updated to use the new PC API DLL for "Concept 1" device
 *
 * Version 1.0.0.0:
 * Date: 17th July 2013
 * Changed by: Lewis Collins
 *   Initial version.
 * ********************************************************************************
 *
 **/

namespace Breakout
{
    /// <summary>
    /// This is the main type for your game
    /// </summary>
    public class Game1 : Microsoft.Xna.Framework.Game, PLTLabsCallbackHandler
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;
        private Texture2D BatTexture, BallTexture, BrickTexture;

        private int m_screenmax_x; // store a copy of max screen coordinate
        private int m_screenmax_y; // store a copy of max screen coordinate
        private int m_halfscreenmax_x; // store a copy of center screen coordinate
        private int m_halfscreenmax_y; // store a copy of center screen coordinate

        Bat m_player1bat;
        Ball m_ball;
        Timer m_increasespeed;
        bool m_gameover = false;
        int m_gamelives = 5;

        // Plantronics innovation head tracking...
        Timer m_autoputoncalibratetimer;  // timer to initiate headtracking calibration after short time delay
        private int headtrack_xoffset = 0; // head track heading offset for sprite
        private int headtrack_yoffset = 0; // head track pitch offset for sprite
        private bool m_worn = false; // flag to know if headset is worn or not
        private PLTConnection m_pltConnection;
        private PLTLabsAPI2 m_pltlabsapi;
        private bool m_calibrated;
        private SpriteFont font;
        KeyboardState oldKeyboardState,
                          currentKeyboardState;// Keyboard state variables
        private Wall m_wall;
        private List<Brick> m_brickkilllist;

        public Game1()
        {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";
        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize()
        {
            // TODO: Add your initialization logic here

            // timer to auto calibrate
            m_autoputoncalibratetimer = new Timer();
            m_autoputoncalibratetimer.Interval = 2000;
            m_autoputoncalibratetimer.AutoReset = false;
            m_autoputoncalibratetimer.Elapsed += autoputoncalibratetimer_Elapsed;

            base.Initialize();
        }

        /// <summary>
        /// LoadContent will be called once per game and is the place to load
        /// all of your content.
        /// </summary>
        protected override void LoadContent()
        {
            // Create a new SpriteBatch, which can be used to draw textures.
            spriteBatch = new SpriteBatch(GraphicsDevice);

            // TODO: use this.Content to load your game content here
            m_increasespeed = new Timer();
            m_increasespeed.Interval = 10000;
            m_increasespeed.Elapsed += new ElapsedEventHandler(m_increasespeed_Elapsed);

            m_player1bat = new Bat();
            m_ball = new Ball();

            BatTexture = Content.Load<Texture2D>("bat");
            BallTexture = Content.Load<Texture2D>("ball");
            BrickTexture = Content.Load<Texture2D>("brick");

            ReconfigureScreen();

            font = Content.Load<SpriteFont>("SpriteFont1");

            // Initialise Plantronics head tracking...
            m_pltlabsapi = new PLTLabsAPI2(this);
        }

        void m_increasespeed_Elapsed(object sender, ElapsedEventArgs e)
        {
            m_ball.xvel += (m_ball.xvel > 0 ? 1 : -1);
            m_ball.yvel += (m_ball.yvel > 0 ? 1 : -1);
        }

        private void CreateWall()
        {
            m_wall = new Wall();
            for (int j = 0; j < 5; j++)
            {
                for (int i = 0; i < (graphics.GraphicsDevice.Viewport.Width / 42); i++)
                {
                    Brick brick = new Brick();

                    brick.xpos = (i * 42) + (BrickTexture.Width / 2) + (graphics.GraphicsDevice.Viewport.Width % 42);
                    brick.ypos = 50 + (j * 16);
                    brick.width = BrickTexture.Width;
                    brick.height = BrickTexture.Height;
                    brick.halfwidth = BrickTexture.Width / 2;
                    brick.halfheight = BrickTexture.Height / 2;
                    brick.hotspot.X = BrickTexture.Width / 2;
                    brick.hotspot.Y = BrickTexture.Height / 2;

                    m_wall.m_bricks.Add(brick);
                }
            }
        }

        private void ReconfigureScreen()
        {
            // Screen
            m_screenmax_x = graphics.GraphicsDevice.Viewport.Width;
            m_screenmax_y = graphics.GraphicsDevice.Viewport.Height;
            m_halfscreenmax_x = m_screenmax_x / 2;
            m_halfscreenmax_y = m_screenmax_y / 2;

            // Bat
            m_player1bat.xpos = m_halfscreenmax_x;
            m_player1bat.ypos = m_screenmax_y - 50;
            m_player1bat.width = BatTexture.Width;
            m_player1bat.height = BatTexture.Height;
            m_player1bat.halfwidth = BatTexture.Width / 2;
            m_player1bat.halfheight = BatTexture.Height / 2;
            m_player1bat.hotspot.X = BatTexture.Width / 2;
            m_player1bat.hotspot.Y = BatTexture.Height / 2;

            // Ball
            ResetBall();

            // Wall
            CreateWall();
        }

        /// <summary>
        /// UnloadContent will be called once per game and is the place to unload
        /// all content.
        /// </summary>
        protected override void UnloadContent()
        {
            // TODO: Unload any non ContentManager content here
            if (m_pltlabsapi!=null)
            {
                m_pltlabsapi.Shutdown();  
            }
        }

        /// <summary>
        /// Allows the game to run logic such as updating the world,
        /// checking for collisions, gathering input, and playing audio.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Update(GameTime gameTime)
        {
            // Allows the game to exit
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed)
                this.Exit();

            // TODO: Add your update logic here
            oldKeyboardState = currentKeyboardState;
            currentKeyboardState = Keyboard.GetState();

            // Thanks: http://mort8088.com/2011/03/06/xna-4-0-tutorial-3-input-from-keyboard/
            // Allows the game to exit
            if ((currentKeyboardState.IsKeyUp(Keys.Escape)) && (oldKeyboardState.IsKeyDown(Keys.Escape)))
            {
                this.Exit();
            }

            // allow toggle fullscreen with F key:
            if ((currentKeyboardState.IsKeyUp(Keys.F)) && (oldKeyboardState.IsKeyDown(Keys.F)))
            {
                graphics.ToggleFullScreen();
                ReconfigureScreen();
            }

            // recalibrate with C key:
            if ((currentKeyboardState.IsKeyUp(Keys.C)) && (oldKeyboardState.IsKeyDown(Keys.C)))
            {
                m_autoputoncalibratetimer.Start();
            }

            // restart game:
            if ((currentKeyboardState.IsKeyUp(Keys.Space)) && (oldKeyboardState.IsKeyDown(Keys.Space)))
            {
                m_gameover = false;
                m_gamelives = 5;
                ReconfigureScreen();
            }

            if (currentKeyboardState.IsKeyDown(Keys.Right))
            {
                headtrack_xoffset += 5;
            }
            if (currentKeyboardState.IsKeyDown(Keys.Left))
            {
                headtrack_xoffset -= 5;
            }

            base.Update(gameTime);
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.Black);

            // TODO: Add your drawing code here
            // Draw the head tracker target on the screen offset from the center of the screen
            // by an amount on x/y axis which is based on the user's head movements
            // (for calculation see HeadsetTrackingUpdate function below)
            spriteBatch.Begin();
            Vector2 pos = new Vector2(m_halfscreenmax_x + headtrack_xoffset, m_player1bat.ypos);  //m_halfscreenmax_y + headtrack_yoffset);
            if (pos.X < m_player1bat.halfwidth) pos.X = m_player1bat.halfwidth;
            if (pos.X > (m_screenmax_x - m_player1bat.halfwidth)) pos.X = (m_screenmax_x - m_player1bat.halfwidth);
            spriteBatch.Draw(BatTexture, pos, null, Color.White, 0f, m_player1bat.hotspot, 1.0f, SpriteEffects.None, 0f);

            // animate the ball and
            // bounce ball off bat
            // idea: use x/y positions and widths to see if they are intersecting

            
            // plan, check bat ball collisions here
            // if they are in collision then move back one unit on x-axis
            // and reverse xvel

            int batxpostemp = m_halfscreenmax_x + headtrack_xoffset;

            if (batxpostemp < m_player1bat.halfwidth) batxpostemp = m_player1bat.halfwidth;
            if (batxpostemp > (m_screenmax_x - m_player1bat.halfwidth)) batxpostemp = (m_screenmax_x - m_player1bat.halfwidth);

            if (!m_gameover)
                CollideDetectBallWithItem(batxpostemp, m_player1bat);

            m_brickkilllist = new List<Brick>();
            foreach (Brick brick in m_wall.m_bricks)
            {
                CollideDetectBallWithItem(brick.xpos, brick, false);
            }

            // destroy bricks:
            foreach (Sprite brick in m_brickkilllist)
            {
                m_wall.m_bricks.Remove((Brick)brick);
            }

            pos.X = m_ball.xpos;
            pos.Y = m_ball.ypos;

            // bounce ball off walls
            if (pos.X < m_ball.halfwidth)
            {
                pos.X = m_ball.halfwidth;
                m_ball.xvel = Math.Abs(m_ball.xvel);
            }
            if (pos.X > (m_screenmax_x - m_ball.halfwidth))
            {
                pos.X = (m_screenmax_x - m_ball.halfwidth);
                m_ball.xvel = -Math.Abs(m_ball.xvel);
            }
            if (pos.Y < m_ball.halfheight)
            {
                pos.Y = m_ball.halfheight;
                m_ball.yvel = Math.Abs(m_ball.yvel);
            }
            if (pos.Y > (m_screenmax_y + m_ball.halfheight))
            {
                ResetBall();
                if (!m_gameover)
                {
                    m_gamelives--;
                }
                if (m_gamelives == 0)
                {
                    m_gameover = true;
                }
            }

            // draw wall
            DrawWall(spriteBatch);

            // draw ball
            if (!m_gameover)
                spriteBatch.Draw(BallTexture, pos, null, Color.White, 0f, m_ball.hotspot, 1.0f, SpriteEffects.None, 0f);

            if (!m_calibrated)
            {
                spriteBatch.DrawString(font, "Awaiting calibration (turn on device, place headset on table)", new Vector2(20, 45), Color.White);
            }
            if (m_autoputoncalibratetimer.Enabled)
            {
                spriteBatch.DrawString(font, "Headset put on, about to calibrate (2 seconds) - Look at center of screen!", new Vector2(20, 25), Color.White);
            }

            spriteBatch.DrawString(font, "Lives = "+m_gamelives, new Vector2(3, 3), Color.White);
            if (m_gameover)
            {
                spriteBatch.DrawString(font, "GAME OVER!\r\nSpace to restart...", new Vector2(m_halfscreenmax_x-50, m_halfscreenmax_y), Color.White);
            }

            spriteBatch.End();

            base.Draw(gameTime);
        }

        private void CollideDetectBallWithItem(int itemxpos, Sprite item, bool isbat = true)
        {
            if (isbat)
                m_ball.xpos += m_ball.xvel;

            Rectangle itemrect = new Rectangle(
                itemxpos - item.halfwidth,
                item.ypos - item.halfheight,
                item.width,
                item.height);
            Rectangle ballrect = new Rectangle(
                m_ball.xpos - m_ball.halfwidth,
                m_ball.ypos - m_ball.halfheight,
                m_ball.width,
                m_ball.height);
            if (!Rectangle.Intersect(itemrect, ballrect).IsEmpty)
            {
                if (!isbat)
                    m_brickkilllist.Add((Brick)item);
                else
                {
                    m_ball.xpos -= m_ball.xvel;
                    m_ball.xvel = -m_ball.xvel;
                }
            }

            if (isbat)
                m_ball.ypos += m_ball.yvel;
            // plan, check bat ball collisions here
            // if there are in collision then move back one unit on y-axis
            // and reverse yvel

            ballrect = new Rectangle(
                m_ball.xpos - m_ball.halfwidth,
                m_ball.ypos - m_ball.halfheight,
                m_ball.width,
                m_ball.height);
            if (!Rectangle.Intersect(itemrect, ballrect).IsEmpty)
            {
                if (!isbat)
                    m_brickkilllist.Add((Brick)item);
                else
                {
                    // accelerate ball depending on position on bat
                    if (itemxpos > m_ball.xpos)
                    {
                        // bat is to right of ball
                        m_ball.xvel -= 1;
                    }
                    else
                    {
                        // bat is to right of ball
                        m_ball.xvel += 1;
                    }

                    m_ball.ypos -= m_ball.yvel;
                    m_ball.yvel = -m_ball.yvel;
                }
            }

        }

        private void DrawWall(SpriteBatch spriteBatch)
        {
            foreach (Brick brick in m_wall.m_bricks)
            {
                Vector2 pos = new Vector2(brick.xpos, brick.ypos);
                spriteBatch.Draw(BrickTexture, pos, null, Color.White, 0f, brick.hotspot, 1.0f, SpriteEffects.None, 0f);
            }
        }

        private void ResetBall()
        {
            // Ball
            m_ball.xpos = m_halfscreenmax_x;
            m_ball.ypos = 150;
            m_ball.width = BallTexture.Width;
            m_ball.height = BallTexture.Height;
            m_ball.halfwidth = BallTexture.Width / 2;
            m_ball.halfheight = BallTexture.Height / 2;
            m_ball.hotspot.X = BallTexture.Width / 2;
            m_ball.hotspot.Y = BallTexture.Height / 2;
            m_ball.xvel = 2;
            m_ball.yvel = 2;
        }

        void autoputoncalibratetimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            // initiate auto calibration
            if (m_pltConnection != null)
            {
                m_pltlabsapi.calibrateService(PLTService.MOTION_TRACKING_SVC);
            }
        }

        // receives headtracking angles in degrees back from PLT Labs API
        public void HeadsetTrackingUpdate(PLTMotionTrackingData headsetData)
        {
            // need to reverse heading and pitch sign?
            headsetData.m_orientation[0] = -headsetData.m_orientation[0];
            //headsetData.m_orientation[1] = -headsetData.m_orientation[1];

            // define some constants for maths calculation to convert head angles into pixel offsets for screen
            const double c_distanceToScreen = 850; // millimeters
            const double c_pixelPitch = 0.25; // millimeters

            double headtrack_offset_millimeters; // temporary variable to hold headset offset

            //if (m_worn)
            //{
                // assume distance from screen is 1 meter and that pixel size is 0.25mm
                headtrack_offset_millimeters = c_distanceToScreen * Math.Tan(headsetData.m_orientation[0] * Math.PI / 180.0); // x = d * tan(theta)
                headtrack_xoffset = (int) (headtrack_offset_millimeters / c_pixelPitch);
                headtrack_offset_millimeters = c_distanceToScreen * Math.Tan(headsetData.m_orientation[1] * Math.PI / 180.0); // y = d * tan(theta)
                headtrack_yoffset = (int)(headtrack_offset_millimeters / c_pixelPitch);
            //}
            //else
            //{
            //    headtrack_xoffset = 0;
            //    headtrack_yoffset = 0;
            //}
        }

        public void ConnectionClosed(PLTDevice pltDevice)
        {
            m_pltConnection = null;
            m_calibrated = false;
        }

        public void ConnectionFailed(PLTDevice pltDevice)
        {
            m_pltConnection = null;
            m_calibrated = false;
        }

        public void ConnectionOpen(PLTConnection pltConnection)
        {
            // lets register for some services
            m_pltConnection = pltConnection;

            if (pltConnection != null)
            {
                m_pltlabsapi.subscribe(PLTService.MOTION_TRACKING_SVC, PLTMode.On_Change);
                m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Offset_Calibrated);
                m_pltlabsapi.configureService(PLTService.MOTION_TRACKING_SVC, PLTConfiguration.MotionSvc_Format_Orientation);
                m_pltlabsapi.subscribe(PLTService.SENSOR_CAL_STATE_SVC, PLTMode.On_Change);
                m_pltlabsapi.subscribe(PLTService.WEARING_STATE_SVC, PLTMode.On_Change);
            }
        }

        public void DeviceAdded(PLTDevice pltDevice)
        {
            if (!m_pltlabsapi.getIsConnected(pltDevice))
            {
                m_pltlabsapi.openConnection(pltDevice);
            }
        }

        public void infoUpdated(PLTConnection pltConnection, PLTInfo pltInfo)
        {
            if (pltInfo != null && pltInfo.m_data != null)
            {
                switch (pltInfo.m_serviceType)
                {
                    case PLTService.SENSOR_CAL_STATE_SVC:
                        PLTSensorCal caldata = (PLTSensorCal)pltInfo.m_data;
                        m_calibrated = caldata.m_isgyrocal;
                        if (m_calibrated)
                        {
                            if (m_increasespeed.Enabled == false)
                            {
                                m_increasespeed.Enabled = true;
                            }
                        }
                        break;
                    case PLTService.MOTION_TRACKING_SVC:
                        PLTMotionTrackingData motiondata = (PLTMotionTrackingData)pltInfo.m_data;
                        HeadsetTrackingUpdate(motiondata);
                        break;
                    case PLTService.WEARING_STATE_SVC:
                        PLTWearingState weardata = (PLTWearingState)pltInfo.m_data;
                        m_worn = weardata.m_worn;
                        if (weardata.m_worn && !weardata.m_isInitialStateEvent)
                        {
                            // headset was put on
                            // lets auto calibrate
                            m_autoputoncalibratetimer.Start();
                        }
                        break;
                }
            }
        }
    }

    // few game objects:
    public class Sprite
    {
        public int xpos;
        public int ypos;
        public int width;
        public int height;
        public int halfwidth;
        public int halfheight;
        public Vector2 hotspot = new Vector2();
        public int xvel;
        public int yvel;
    }

    public class Bat : Sprite
    {
    }

    public class Ball : Sprite
    {
    }

    public class Brick : Sprite
    {
    }

    public class Wall
    {
        public List<Brick> m_bricks = new List<Brick>();
    }
}
