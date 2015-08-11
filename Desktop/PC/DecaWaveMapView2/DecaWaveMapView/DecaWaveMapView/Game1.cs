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
using System.Threading;
using System.Net.Sockets;
using System.Net;
using System.Text;
using System.Collections;
using System.Reflection;

namespace DecaWaveMapView
{
    /// <summary>
    /// Marauder's Map Decawave sample application
    /// v1.0.0.10
    /// 
    /// Example usage (can pass command line params:
    /// 
    ///   DecaWaveMapView 10.76.201.21 9050 debugon
    ///   
    /// NOTE: defaults are 10.76.201.21 9050 debugoff
    /// </summary>
    public class Game1 : Microsoft.Xna.Framework.Game
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;
        private Texture2D SpriteTexture;
        private SpriteFont font;
        Texture2D backgroundTexture;
        KeyboardState oldKeyboardState,
                          currentKeyboardState;// Keyboard state variables

        private int m_screenmax_x; // store a copy of max screen coordinate
        private int m_screenmax_y; // store a copy of max screen coordinate
        private int m_halfscreenmax_x; // store a copy of center screen coordinate
        private int m_halfscreenmax_y; // store a copy of center screen coordinate
        private float m_scalefactor = 32.11007f; // test use Roll angle to scale crosshair
        private BasicEffect basicEffect;
        bool m_inv_x = true;
        bool m_inv_y = false;
        private float m_mapscalefactor = 0.02935831f;
        private float m_xmapscalefactor = 0.8221221f;
        private float m_maprotate = 0.0f;
        private float m_mapoffset_x = -2.729818f;
        private float m_mapoffset_y = 3.779978f;
        private Vector2 m_maporigin;

        private float m_masteroffset_x = -14.93995f;
        private float m_masteroffset_y = -10.13007f;

        // sprite image allocation
        List<TagImage> m_tagimages = new List<TagImage>();
        int m_nextimage = 1;

        // DecaWave connection
        static readonly object m_guiUpdateLock = new object();
        Dictionary<string, TagXYZ> m_tags = new Dictionary<string, TagXYZ>();

        // breadcrumbs display (track user's motion!)
        List<BreadCrumb> m_breadcrumbs = new List<BreadCrumb>();
        System.Timers.Timer m_breadcrumbtimer;
        static readonly object m_breadcrumbUpdateLock = new object();
        private decimal c_breadcrumpdistance = 1m; // minimum distance between breadcrumbs

        // markers display (mark features on map with M key)
        List<Marker> m_markers = new List<Marker>();
        static readonly object m_markersUpdateLock = new object();
        private int c_markerImageNumber = 2;
        private bool c_debugmode = false;

        private static string APP_NAME = "Plantronics DecaWave Client Test";
        private static string m_assemblyVersion;
        private static string m_fileVersion;
        private static volatile object m_loglocker = new Object();
        private static volatile bool m_quit = false; // using volatile so can access/update from multiple threads

        private static string m_host = "10.76.201.21";
        private static int m_port = 9050;
        private static bool m_debug = false;

        private static SocketConnector connector;

        private DebugForm m_debugwindow = null;
        private string[] m_args;
        private bool m_showanchors = false;
        private Texture2D m_anchorimage;
        private Vector2 m_anchororigin;
        private Vector2[] m_anchorpositions = new []
            {
                new Vector2(16.3f,2.85f),
                new Vector2(11.1f,4.2f),
                new Vector2(17.1f,14.2f),
                new Vector2(12.8f,11.9f),
                new Vector2(18.75f,18.6f),
                new Vector2(9.4f,20.0f)
            };


        public Game1(string[] args)
        {
            m_args = args;
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";

            graphics.PreferredBackBufferWidth = 1024;
            graphics.PreferredBackBufferHeight = 768;
        }

        /// <summary>
        /// Allows the game to perform any initialization it needs to before starting to run.
        /// This is where it can query for any required services and load any non-graphic
        /// related content.  Calling base.Initialize will enumerate through any components
        /// and initialize them as well.
        /// </summary>
        protected override void Initialize()
        {
            // new, game config form
            DoOpenDebugWindow();

            // TODO: Add your initialization logic here
            if (m_args.Count() > 0)
            {
                m_host = m_args[0];
                if (m_args.Count() > 1)
                {
                    try
                    {
                        m_port = Convert.ToInt32(m_args[1]);
                    }
                    catch (Exception)
                    {
                        m_port = 9050;
                    }
                }
                if (m_args.Count() > 2)
                {
                    try
                    {
                        m_debug = (m_args[2].ToUpper() == "DEBUGON");
                    }
                    catch (Exception)
                    {
                        m_debug = false;
                    }
                }
            }

            connector = new SocketConnector(m_host, m_port, this);
            connector.Connected += new SocketConnector.ConnectedEventHandler(connector_Connected);
            connector.MessageReceived += new SocketConnector.MessageReceivedEventHandler(connector_MessageReceived);

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
            m_tagimages.Add(new TagImage(Content.Load<Texture2D>("Lewis")));
            m_tagimages.Add(new TagImage(Content.Load<Texture2D>("Andy")));
            m_tagimages.Add(new TagImage(Content.Load<Texture2D>("Simon")));
            m_tagimages.Add(new TagImage(Content.Load<Texture2D>("targetcrosshairs")));
            c_markerImageNumber = m_tagimages.Count() - 1;
            m_screenmax_x = graphics.GraphicsDevice.Viewport.Width;
            m_screenmax_y = graphics.GraphicsDevice.Viewport.Height;
            m_halfscreenmax_x = m_screenmax_x / 2;
            m_halfscreenmax_y = m_screenmax_y / 2;

            m_anchorimage = Content.Load<Texture2D>("Anchor");
            m_anchororigin.X = m_anchorimage.Width / 2;
            m_anchororigin.Y = m_anchorimage.Height / 2;

            font = Content.Load<SpriteFont>("SpriteFont1");

            backgroundTexture = Content.Load<Texture2D>("RWBmap-sml-inv");
            m_maporigin.X = backgroundTexture.Width / 2;
            m_maporigin.Y = backgroundTexture.Height / 2;

            // line drawing stuff: http://stackoverflow.com/questions/270138/how-do-i-draw-lines-using-xna
            basicEffect = new BasicEffect(GraphicsDevice);
            basicEffect.VertexColorEnabled = true;
            basicEffect.Projection = Matrix.CreateOrthographicOffCenter
            (0, GraphicsDevice.Viewport.Width,     // left, right
            GraphicsDevice.Viewport.Height, 0,    // bottom, top
            0, 1);   

            // FOR DEBUG PURPOSES ONLY -- add dummy tag controlled by keyboard
            if (c_debugmode)
            {
                m_tags.Add("dummy", new TagXYZ(15, 0, 0, getNextImage("dummy")));
                m_tags.Add("old_dummy", new TagXYZ(15, 0, 0, null)); // old_ tag records are used to track the "last" position
                // so we know when it moves > c_breadcrumpdistance from that position
            }

            //m_breadcrumbs.Add(new BreadCrumb(DateTime.Now, 30, 0, 0));
            m_breadcrumbtimer = new System.Timers.Timer();
            m_breadcrumbtimer.Interval = 1000;
            m_breadcrumbtimer.Elapsed += new System.Timers.ElapsedEventHandler(m_breadcrumbtimer_Elapsed);
            m_breadcrumbtimer.Start();

            this.IsMouseVisible = true;
        }

        // get the next available sprite image to assign to a tag
        private TagImage getNextImage(string tagid)
        {
            // if we know the tag id, assign that image
            // otherwise assign random?

            TagImage retval;
            switch (tagid)
            {
                case "0xDECA313033614013":
                    retval = m_tagimages[0];
                    break;
                case "0xDECA393031102335":
                    retval = m_tagimages[1];
                    break;
                case "0xDECA363031100F1A":
                    retval = m_tagimages[2];
                    break;
                default:
                    retval = m_tagimages[m_nextimage];
                    break;
            }
            m_nextimage++;
            if (m_nextimage > c_markerImageNumber - 1) m_nextimage = 0;
            return retval;
        }

        void m_breadcrumbtimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            List<BreadCrumb> killList = new List<BreadCrumb>();

            lock (m_breadcrumbUpdateLock)
            {
                // iterate breadcrumbs, fading them, and if they are too old, removing them
                foreach (BreadCrumb breadcrumb in m_breadcrumbs)
                {
                    if (breadcrumb.brightness > 0)
                    {
                        breadcrumb.brightness -= 10;
                        if (breadcrumb.brightness < 0)
                            breadcrumb.brightness = 0;
                    }
                    else
                    {
                        killList.Add(breadcrumb);
                    }
                }

                // remove expired breadcrumbs
                foreach (BreadCrumb bc in killList)
                {
                    m_breadcrumbs.Remove(bc);
                }
            }
        }

        /// <summary>
        /// UnloadContent will be called once per game and is the place to unload
        /// all content.
        /// </summary>
        protected override void UnloadContent()
        {
            // TODO: Unload any non ContentManager content here
            m_debugwindow.SetExitting(true);
            RemoveDebugWindow();
            RequestStop();
            m_breadcrumbtimer.Stop();
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
            // ESC - Allows the game to exit
            if ((currentKeyboardState.IsKeyUp(Keys.Escape)) && (oldKeyboardState.IsKeyDown(Keys.Escape)))
            {
                this.Exit();
            }

            // PageUp/PageDown - allow to zoom in and out (scale the tag coordinate system)
            if ((currentKeyboardState.IsKeyUp(Keys.PageUp)) && (oldKeyboardState.IsKeyDown(Keys.PageUp)))
            {
                m_scalefactor = m_scalefactor * (currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 1.05f : 1.5f);
            }
            if ((currentKeyboardState.IsKeyUp(Keys.PageDown)) && (oldKeyboardState.IsKeyDown(Keys.PageDown)))
            {
                m_scalefactor = m_scalefactor / (currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 1.05f : 1.5f);
                if (m_scalefactor < 1.0f) m_scalefactor = 1.0f;
            }

            // F - allow toggle fullscree:
            if ((currentKeyboardState.IsKeyUp(Keys.F)) && (oldKeyboardState.IsKeyDown(Keys.F)))
            {
                graphics.ToggleFullScreen();
                m_screenmax_x = graphics.GraphicsDevice.Viewport.Width;
                m_screenmax_y = graphics.GraphicsDevice.Viewport.Height;
                m_halfscreenmax_x = m_screenmax_x / 2;
                m_halfscreenmax_y = m_screenmax_y / 2;
            }

            // D - open debug window
            if ((currentKeyboardState.IsKeyUp(Keys.D)) && (oldKeyboardState.IsKeyDown(Keys.D)))
            {
                if (m_debugwindow == null)
                {
                    DoOpenDebugWindow();
                }
            }

            // add markers at current positions of all the tags in tag list
            if ((currentKeyboardState.IsKeyUp(Keys.M)) && (oldKeyboardState.IsKeyDown(Keys.M)))
            {
                // 1. get current position of first tag in tag list
                lock (m_guiUpdateLock)
                {
                    // if shifted just delete all markers
                    if (currentKeyboardState.IsKeyDown(Keys.LeftShift))
                    {
                        lock (m_markersUpdateLock)
                        {
                            m_markers.Clear();
                        }
                    }
                    else
                    {
                        if (m_tags.Count() > 1)
                        {
                            IEnumerator enumerator = m_tags.Keys.GetEnumerator();
                            while (enumerator.MoveNext())
                            {
                                string key = (string)enumerator.Current;
                                if (!key.StartsWith("old_"))
                                {
                                    TagXYZ aTag = m_tags[key];
                                    if (aTag != null)
                                    {
                                        // 2. create a marker
                                        lock (m_markersUpdateLock)
                                        {
                                            m_markers.Add(new Marker(aTag.x, aTag.y, aTag.z, m_tagimages[c_markerImageNumber]));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // turn on and off DEBUG mode
            if ((currentKeyboardState.IsKeyUp(Keys.Insert)) && (oldKeyboardState.IsKeyDown(Keys.Insert)))
            {
                c_debugmode = !c_debugmode;

                if (c_debugmode)
                {
                    lock (m_guiUpdateLock)
                    {
                        m_tags.Add("dummy", new TagXYZ(15, 0, 0, getNextImage("dummy")));
                        m_tags.Add("old_dummy", new TagXYZ(15, 0, 0, null)); // old_ tag records are used to track the "last" position
                    }
                }
                else
                {
                    lock (m_guiUpdateLock)
                    {
                        m_tags.Remove("dummy");
                        m_tags.Remove("old_dummy");
                    }
                }
            }

            if (c_debugmode)
            {
                // allow invert x/y axes:
                if ((currentKeyboardState.IsKeyUp(Keys.X)) && (oldKeyboardState.IsKeyDown(Keys.X)))
                {
                    m_inv_x = !m_inv_x;
                }
                if ((currentKeyboardState.IsKeyUp(Keys.Y)) && (oldKeyboardState.IsKeyDown(Keys.Y)))
                {
                    m_inv_y = !m_inv_y;
                }

                // allow keyboard to move "dummy" tag
                if (m_tags.ContainsKey("dummy"))
                {
                    TagXYZ dummytag = m_tags["dummy"];
                    if (dummytag != null)
                    {
                        if (currentKeyboardState.IsKeyDown(Keys.Left))
                        {
                            UpdateTagXYZ("dummy", dummytag.x - (!m_inv_x ? 0.2m : -0.2m), dummytag.y, dummytag.z);
                        }
                        else if (currentKeyboardState.IsKeyDown(Keys.Right))
                        {
                            UpdateTagXYZ("dummy", dummytag.x + (!m_inv_x ? 0.2m : -0.2m), dummytag.y, dummytag.z);
                        }
                        dummytag = m_tags["dummy"];
                        if (currentKeyboardState.IsKeyDown(Keys.Up))
                        {
                            UpdateTagXYZ("dummy", dummytag.x, dummytag.y - (!m_inv_y ? 0.2m : -0.2m), dummytag.z);
                        }
                        else if (currentKeyboardState.IsKeyDown(Keys.Down))
                        {
                            UpdateTagXYZ("dummy", dummytag.x, dummytag.y + (!m_inv_y ? 0.2m : -0.2m), dummytag.z);
                        }
                    }
                }

                // manipulate the map
                if (currentKeyboardState.IsKeyDown(Keys.Q))
                {
                    m_maprotate -= currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 0.1f : 1f;
                    if (m_maprotate < 0.0f) m_maprotate = m_maprotate + 360.0f;
                }
                else if (currentKeyboardState.IsKeyDown(Keys.E))
                {
                    m_maprotate += currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 0.1f : 1f;
                    if (m_maprotate >= 360.0f) m_maprotate = m_maprotate - 360.0f;
                }
                if (currentKeyboardState.IsKeyDown(Keys.Z))
                {
                    m_mapscalefactor = m_mapscalefactor * (currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 1.001f : 1.01f);
                }
                else if (currentKeyboardState.IsKeyDown(Keys.C))
                {
                    m_mapscalefactor = m_mapscalefactor / (currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 1.001f : 1.01f);
                    if (m_mapscalefactor < 0.0001f) m_mapscalefactor = 0.0001f;
                }

                // map x scale factor (stretch map)
                if (currentKeyboardState.IsKeyDown(Keys.G))
                {
                    m_xmapscalefactor = m_xmapscalefactor * (currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 1.001f : 1.01f);
                }
                else if (currentKeyboardState.IsKeyDown(Keys.B))
                {
                    m_xmapscalefactor = m_xmapscalefactor / (currentKeyboardState.IsKeyDown(Keys.LeftShift) ? 1.001f : 1.01f);
                    if (m_xmapscalefactor < 0.0001f) m_xmapscalefactor = 0.0001f;
                }

                // move the map offsets
                if (currentKeyboardState.IsKeyDown(Keys.A))
                {
                    m_mapoffset_x -= (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_x ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_x ?
                        1.0f : -1.0f)
                        );
                }
                else if (currentKeyboardState.IsKeyDown(Keys.D))
                {
                    m_mapoffset_x += (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_x ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_x ?
                        1.0f : -1.0f)
                        );
                }
                if (currentKeyboardState.IsKeyDown(Keys.W))
                {
                    m_mapoffset_y -= (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_y ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_y ?
                        1.0f : -1.0f)
                        );
                }
                else if (currentKeyboardState.IsKeyDown(Keys.S))
                {
                    m_mapoffset_y += (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_y ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_y ?
                        1.0f : -1.0f)
                        );
                }


                // master offset - move everything
                if (currentKeyboardState.IsKeyDown(Keys.J))
                {
                    m_masteroffset_x -= (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_x ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_x ?
                        1.0f : -1.0f)
                        );
                }
                else if (currentKeyboardState.IsKeyDown(Keys.L))
                {
                    m_masteroffset_x += (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_x ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_x ?
                        1.0f : -1.0f)
                        );
                }
                if (currentKeyboardState.IsKeyDown(Keys.I))
                {
                    m_masteroffset_y -= (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_y ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_y ?
                        1.0f : -1.0f)
                        );
                }
                else if (currentKeyboardState.IsKeyDown(Keys.K))
                {
                    m_masteroffset_y += (currentKeyboardState.IsKeyDown(Keys.LeftShift) ?
                        (!m_inv_y ?
                        0.01f : -0.01f)
                        :
                        (!m_inv_y ?
                        1.0f : -1.0f)
                        );
                }
            }
            else
            {
                // non debug mode commands
                // A - show anchors
                if ((currentKeyboardState.IsKeyUp(Keys.A)) && (oldKeyboardState.IsKeyDown(Keys.A)))
                {
                    m_showanchors = !m_showanchors;
                }
            }

            base.Update(gameTime);
        }

        private void DoOpenDebugWindow()
        {
            m_debugwindow = new DebugForm(this);
            m_debugwindow.Show();
            m_debugwindow.BringToFront();
        }

        /// <summary>
        /// This is called when the game should draw itself.
        /// </summary>
        /// <param name="gameTime">Provides a snapshot of timing values.</param>
        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.Black);

            // TODO: Add your drawing code here

            spriteBatch.Begin();

            // draw the map
            float tmpmapx = (m_mapoffset_x + m_masteroffset_x) * m_scalefactor;
            if (m_inv_x) tmpmapx = -tmpmapx;
            float tmpmapy = (m_mapoffset_y + m_masteroffset_y) * m_scalefactor;
            if (m_inv_y) tmpmapy = -tmpmapy;
            Vector2 backgrpos = new Vector2(m_halfscreenmax_x + tmpmapx,
                m_halfscreenmax_y + tmpmapy);

            Vector2 nonuniformscale = Vector2.One;
            nonuniformscale.Y = m_mapscalefactor * m_scalefactor;
            nonuniformscale.X = m_mapscalefactor * m_scalefactor * m_xmapscalefactor;
            
            spriteBatch.Draw(backgroundTexture,
                backgrpos, null, Color.White, MathHelper.ToRadians(m_maprotate), m_maporigin, nonuniformscale, SpriteEffects.None, 0f);

            lock (m_breadcrumbUpdateLock)
            {
                // iterate breadcrumbs, drawing them
                foreach (BreadCrumb breadcrumb in m_breadcrumbs)
                {
                    float tmpx = ((float)breadcrumb.x + m_masteroffset_x) * m_scalefactor;
                    if (m_inv_x) tmpx = -tmpx;
                    float tmpy = ((float)breadcrumb.y + m_masteroffset_y) * m_scalefactor;
                    if (m_inv_y) tmpy = -tmpy;
                    Vector2 pos = new Vector2(m_halfscreenmax_x + tmpx,
                        m_halfscreenmax_y + tmpy);
                    spriteBatch.Draw(breadcrumb.myImage.myTexture, pos, null,
                        new Color(breadcrumb.brightness, breadcrumb.brightness, breadcrumb.brightness),
                        0f, breadcrumb.myImage.myOrigin, 1.0f, SpriteEffects.None, 0f);
                }
            }

            lock (m_markersUpdateLock)
            {
                // iterate markers, drawing them
                foreach (Marker marker in m_markers)
                {
                    float tmpx = ((float)marker.x + m_masteroffset_x) * m_scalefactor;
                    if (m_inv_x) tmpx = -tmpx;
                    float tmpy = ((float)marker.y + m_masteroffset_y) * m_scalefactor;
                    if (m_inv_y) tmpy = -tmpy;
                    Vector2 pos = new Vector2(m_halfscreenmax_x + tmpx,
                        m_halfscreenmax_y + tmpy);
                    spriteBatch.Draw(marker.myImage.myTexture, pos, null,
                        new Color(255, 0, 0),
                        0f, marker.myImage.myOrigin, 1.0f, SpriteEffects.None, 0f);
                }
            }

            // now iterate tags, drawing them
            lock (m_guiUpdateLock)
            {
                foreach (var pair in m_tags)
                {
                    if (!pair.Key.StartsWith("old_"))  // don't draw the "old" tag records that are tracking last positions
                    {
                        string key = pair.Key;
                        TagXYZ value = pair.Value;
                        float tmpx = ((float)value.x + m_masteroffset_x) * m_scalefactor;
                        if (m_inv_x) tmpx = -tmpx;
                        float tmpy = ((float)value.y + m_masteroffset_y) * m_scalefactor;
                        if (m_inv_y) tmpy = -tmpy;
                        Vector2 pos = new Vector2(m_halfscreenmax_x + tmpx,
                            m_halfscreenmax_y + tmpy);
                        spriteBatch.Draw(value.myImage.myTexture, pos, null, Color.White, 0f, value.myImage.myOrigin, 0.5f, SpriteEffects.None, 0f);
                    }
                }
            }

            if (c_debugmode)
            {
                Vector2 textpos = new Vector2(20, 25);
                spriteBatch.DrawString(font, "DEBUG INFO:", textpos, Color.White);
                textpos.Y += 30;
                spriteBatch.DrawString(font, "scale: " + m_scalefactor, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "max_x: " + m_screenmax_x, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "max_y: " + m_screenmax_y, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "hmx: " + m_halfscreenmax_x, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "hmy: " + m_halfscreenmax_y, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "mapscale: " + m_mapscalefactor, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "maprot: " + m_maprotate, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "mapoffsetx: " + m_mapoffset_x, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "mapoffsety: " + m_mapoffset_y, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "mastoffx: " + m_masteroffset_x, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "mastoffy: " + m_masteroffset_y, textpos, Color.White);
                textpos.Y += 20;
                spriteBatch.DrawString(font, "mapxscale: " + m_xmapscalefactor, textpos, Color.White);
            }

            // render the tag position info
            spriteBatch.DrawString(font, "TAGS:", new Vector2(20, 10 + (c_debugmode ? 360 : 0)), Color.White);

            lock (m_guiUpdateLock)
            {
                int i = 0;
                foreach (var pair in m_tags)
                {
                    if (!pair.Key.StartsWith("old_"))  // don't draw the "old" tag records that are tracking last positions
                    {
                        string key = pair.Key;
                        TagXYZ value = pair.Value;
                        Vector2 pos = new Vector2(60, 40 + (c_debugmode ? 360 : 0) + (i * 60));
                        spriteBatch.DrawString(font, "X: " + value.x, pos, Color.White);
                        pos.Y += 20;
                        spriteBatch.DrawString(font, "Y: " + value.y, pos, Color.White);
                        pos.X -= 25;
                        spriteBatch.Draw(value.myImage.myTexture, pos, null, Color.White, 0f, value.myImage.myOrigin, 0.5f, SpriteEffects.None, 0f);
                        i++;
                    }                        
                }
            }

            // draw lines
            if (c_debugmode)
            {
                basicEffect.CurrentTechnique.Passes[0].Apply();
                var vertices = new VertexPositionColor[8];
                vertices[0].Position = new Vector3(m_halfscreenmax_x, 0, 0);
                vertices[0].Color = Color.Black;
                vertices[1].Position = new Vector3(m_halfscreenmax_x, m_halfscreenmax_y, 0);
                vertices[1].Color = Color.White;
                vertices[2].Position = new Vector3(0, m_halfscreenmax_y, 0);
                vertices[2].Color = Color.Black;
                vertices[3].Position = new Vector3(m_halfscreenmax_x, m_halfscreenmax_y, 0);
                vertices[3].Color = Color.White;

                vertices[4].Position = new Vector3(m_halfscreenmax_x, m_screenmax_y, 0);
                vertices[4].Color = Color.Black;
                vertices[5].Position = new Vector3(m_halfscreenmax_x, m_halfscreenmax_y, 0);
                vertices[5].Color = Color.White;
                vertices[6].Position = new Vector3(m_screenmax_x, m_halfscreenmax_y, 0);
                vertices[6].Color = Color.Black;
                vertices[7].Position = new Vector3(m_halfscreenmax_x, m_halfscreenmax_y, 0);
                vertices[7].Color = Color.White;

                GraphicsDevice.DrawUserPrimitives<VertexPositionColor>(PrimitiveType.LineList, vertices, 0, 4);
            }

            // draw anchors?
            if (m_showanchors)
            {
                foreach (Vector2 anchorpos in m_anchorpositions)
                {
                    float tmpx = (anchorpos.X + m_masteroffset_x) * m_scalefactor;
                    if (m_inv_x) tmpx = -tmpx;
                    float tmpy = (anchorpos.Y + m_masteroffset_y) * m_scalefactor;
                    if (m_inv_y) tmpy = -tmpy;
                    Vector2 pos = new Vector2(m_halfscreenmax_x + tmpx,
                        m_halfscreenmax_y + tmpy);
                    spriteBatch.Draw(m_anchorimage,
                        pos, null, Color.White, 0f, m_anchororigin, 0.5f, SpriteEffects.None, 0f);
                }
            }

            spriteBatch.End();

            base.Draw(gameTime);
        }

        public void UpdateTagXYZ(string id, Decimal x, Decimal y, Decimal z)
        {
            lock (m_guiUpdateLock)
            {
                // see if tag coords have changed
                if (m_tags.ContainsKey(id))
                {
                    TagXYZ oldtag = m_tags["old_" + id];
                    if (oldtag != null)
                    {
                        if (Math.Abs(oldtag.x - x) > c_breadcrumpdistance ||
                            Math.Abs(oldtag.y - y) > c_breadcrumpdistance ||
                            Math.Abs(oldtag.z - z) > c_breadcrumpdistance)
                        {
                            lock (m_breadcrumbUpdateLock)
                            {
                                // add a breadcrumb to show old position
                                m_breadcrumbs.Add(new BreadCrumb(DateTime.Now, oldtag.x, oldtag.y, oldtag.z, m_tagimages[c_markerImageNumber]));
                            }
                            m_tags.Remove("old_" + id); // remove old last position
                            m_tags.Add("old_" + id, new TagXYZ(x, y, z, null)); // add new last position
                        }
                    }
                    else
                    {
                        m_tags.Add("old_" + id, new TagXYZ(x, y, z, null)); // add new last position
                    }
                    TagImage theImage = m_tags[id].myImage;
                    m_tags.Remove(id); // remove tag record
                    m_tags.Add(id, new TagXYZ(x, y, z, theImage)); // add updated tag record
                }
                else
                {
                    m_tags.Add(id, new TagXYZ(x, y, z, getNextImage(id))); // add updated tag record
                    m_tags.Add("old_" + id, new TagXYZ(x, y, z, null)); // add new last position
                }
            }
        }

        void connector_MessageReceived(object sender, SocketConnector.MessageReceivedArgs e)
        {
            string recv = "";
            try {
                if (e.Message!=null && e.Message.Length>0)
                {
                    string recvstr = e.Message;
                    string[] recv2 = recvstr.Split(new[] { "}{" }, StringSplitOptions.RemoveEmptyEntries);
                    if (recv2 == null || recv2.Count() == 0)
                    {
                        recv2 = new string[1];
                        recv2[0] = e.Message;
                    }
                    if (recv2.Count() > 0)
                    {
                        LogMessage(MethodInfo.GetCurrentMethod().Name, "recv'd " + recv2.Count() + " lines.");
                        int i = 0;
                        foreach (string recviter in recv2)
                        {
                            // hack repair 2
                            recv = recviter.Replace("{{", "{");
                            recv = recv.Replace("}}", "}");

                            // hack repair strings
                            if (i == 0 && !recv.EndsWith("}"))
                            {
                                recv += "}";
                            }
                            if (i > 0 && i < recv2.Count() - 1)
                            {
                                if (!recv.StartsWith("{"))
                                    recv = "{" + recv;
                                if (!recv.EndsWith("}"))
                                    recv = recv + "}";
                            }
                            if (i == recv2.Count() - 1)
                            {
                                if (!recv.StartsWith("{"))
                                    recv = "{" + recv;
                            }

                            //LogMessage(MethodInfo.GetCurrentMethod().Name, "LS: Received: ");
                            var tagMsg = System.Web.Helpers.Json.Decode(recv);
                            if (tagMsg != null &&
                                tagMsg.id != null &&
                                tagMsg.coordinates != null &&
                                tagMsg.coordinates.x != null &&
                                tagMsg.coordinates.y != null)
                            {
                                //LogMessage(MethodInfo.GetCurrentMethod().Name, 
                                //    string.Format("ID: {0}, x: {1}, y: {2}",
                                //    tagMsg.id,
                                //    tagMsg.coordinates.x,
                                //    tagMsg.coordinates.y
                                //    )
                                //);

                                UpdateTagXYZ(
                                    tagMsg.id,
                                    tagMsg.coordinates.x,
                                    tagMsg.coordinates.y,
                                    tagMsg.coordinates.z);
                            }
                            else
                            {
                                LogMessage(MethodInfo.GetCurrentMethod().Name, "LS: Recv'd tag msg with NO coords ");
                                if (tagMsg != null &&
                                    tagMsg.id != null)
                                {
                                    LogMessage(MethodInfo.GetCurrentMethod().Name, "from tag ID: " + tagMsg.id);
                                }
                                LogMessage(MethodInfo.GetCurrentMethod().Name, "");
                            }
                            i++;
                        }
                    }
                    else
                    {
                        LogMessage(MethodInfo.GetCurrentMethod().Name, "LS: Recv'd msg with no data");
                    }
                }
                else
                {
                    LogMessage(MethodInfo.GetCurrentMethod().Name, "LS: Received empty");
                }
            }
            catch (Exception exc)
            {
                LogMessage(MethodInfo.GetCurrentMethod().Name, "INFO: "+exc);
                //throw new Exception("message receive error", exc);
            }
        }

        public void LogMessage(string callingmethodname, string message)
        {
            if (m_debugwindow != null)
            {
                m_debugwindow.AppendToOutputWindow(callingmethodname, message);
            }
        }

        void connector_Connected(object sender, EventArgs e)
        {
            connector.SendCommand("LOGON SHAYWARD-I");
            connector.SendCommand("SUBSCRIBEALL");
        }

        public void RequestStop()
        {
            connector.ShutDown();
        }

        internal void RemoveDebugWindow()
        {
            m_debugwindow = null;
        }
    }

    public class TagXYZ
    {
        public Decimal x;
        public Decimal y;
        public Decimal z;
        public TagImage myImage;

        public TagXYZ(Decimal x, Decimal y, Decimal z, TagImage myImage)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.myImage = myImage;
        }
    }

    public class BreadCrumb : TagXYZ
    {
        public int brightness;
        public DateTime born;

        public BreadCrumb(DateTime born, Decimal x, Decimal y, Decimal z, TagImage myImage)
            : base(x, y, z, myImage)
        {
            this.born = born;
            this.brightness = 120; // starting brightness (alpha value, fade from 200 to 0)
        }
    }

    public class Marker : TagXYZ
    {
        public Marker(Decimal x, Decimal y, Decimal z, TagImage myImage)
            : base(x, y, z, myImage)
        {
        }
    }

    public class TagImage
    {
        public Texture2D myTexture;
        public Vector2 myOrigin;

        public TagImage(Texture2D image)
        {
            myTexture = image;
            myOrigin.X = myTexture.Width / 2;
            myOrigin.Y = myTexture.Height / 2;
        }
    }
}
