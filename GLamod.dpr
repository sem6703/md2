program GLamod;

uses
  Messages,
  Windows,
  OpenGL,
  Textures,
  MD2;

const
  TITLE = 'OpenGL application by Vashchaev Ivan';
  WIDTH = 640;
  HEIGHT = 480;

  FILE_MODEL = 'base\female\tris.md2'; //  1\  
  //FILE_MODEL = 'base\fiona\tris.md2'; //  1\
  //FILE_SKIN_MODEL = 'base\female\skin.tga';  /// fiona
  //FILE_SKIN_MODEL = 'base\fiona\skin.tga';  //     female
  //FILE_WEAPON_MODEL = 'base\weapon.md2';
  //FILE_SKIN_WEAPON_MODEL = 'base\weapon.tga';

var
  Handle: hWnd;
  DC: HDC;
  HRC: HGLRC;
  Keys: array [0..255] of Boolean;

  Skin, WeaponSkin: Cardinal;
  Model, WeaponModel: T3DModel;
  X, Y: Single;
  Fill: Boolean = True;



// Render an actual scene
procedure Render;
var i, WhichVertex,
    Index1, Index2: Integer;
begin
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 {     }
 glPushMatrix;

 gluLookAt(0.0, 0.0, -90.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
 glRotatef(X, 0.0, 1.0, 0.0);
 glRotatef(Y, 0.0, 0.0, 1.0);

 if Fill
  then glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
  else glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

 EnableTexture(Skin);
 AnimateModel(Model);//собствено отображение модели


// EnableTexture(WeaponSkin);
// AnimateModel(WeaponModel);

 glPopMatrix;
 
 SwapBuffers(DC);
end;

// Processing keys
procedure ProcessKeys;
begin
 if Keys[VK_ESCAPE] then PostQuitMessage(0);

 if Keys[VK_UP] then Y := Y + 1.0;
 if Keys[VK_DOWN] then Y := Y - 1.0;
 if Keys[VK_LEFT] then X := X - 1.0;
 if Keys[VK_RIGHT] then X := X + 1.0;
end;

// Setup DC pixel format
procedure SetPixFormat(HDC: HDC);
var pfd: TPixelFormatDescriptor;
    nPixelFormat: Integer;
begin
 with pfd do
  begin
   nSize := SizeOf(TPixelFormatDescriptor); // размер структуры
   nVersion := 1;                           // номер версии
   dwFlags := PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL; // множество битовых флагов, определ€ющих устройство и интерфейс
   iPixelType := PFD_TYPE_RGBA; // режим дл€ изображени€ цветов
   cColorBits := 32;            // число битовых плоскостей в каждом буфере цвета
   cRedBits := 0;               // число битовых плоскостей красного в каждом буфере RGBA
   cRedShift := 0;              // смещение от начала числа битовых плоскостей красного в каждом буфере RGBA
   cGreenBits := 0;             // число битовых плоскостей зелЄного в каждом буфере RGBA
   cGreenShift := 0;            // смещение от начала числа битовых плоскостей зелЄного в каждом буфере RGBA
   cBlueBits := 0;              // число битовых плоскостей синего в каждом буфере RGBA
   cBlueShift := 0;             // смещение от начала числа битовых плоскостей синего в каждом буфере RGBA
   cAlphaBits := 0;             // число битовых плоскостей альфа в каждом буфере RGBA
   cAlphaShift := 0;            // смещение от начала числа битовых плоскостей альфа в каждом буфере RGBA
   cAccumBits := 0;             // общее число битовых плоскостей в буфере аккумул€тора
   cAccumRedBits := 0;          // число битовых плоскостей красного в буфере аккумул€тора
   cAccumGreenBits := 0;        // число битовых плоскостей зелЄного в буфере аккумул€тора
   cAccumBlueBits := 0;         // число битовых плоскостей синего в буфере аккумул€тора
   cAccumAlphaBits := 0;        // число битовых плоскостей альфа в буфере аккумул€тора
   cDepthBits := 32;            // размер буфера глубины (ось z)
   cStencilBits := 0;           // размер буфера трафарета
   cAuxBuffers := 0;            // число вспомогательных буферов
   iLayerType := PFD_MAIN_PLANE;// тип плоскости
   bReserved := 0;              // число плоскостей переднего и заднего плана
   dwLayerMask := 0;            // игнорируетс€
   dwVisibleMask := 0;          // индекс или цвет прозрачности нижней плоскости
   dwDamageMask := 0;           // игнорируетс€
  end;

 nPixelFormat := ChoosePixelFormat(HDC, @pfd); // запрос системе - поддерживаетс€ ли выбранный формат пикселей
 SetPixelFormat(HDC, nPixelFormat, @pfd);      // устанавливаем формат пикселей в контексте устройства
end;

// Initialize OpenGL
procedure InitializeGL;
begin
// GL
 DC := GetDC(Handle);
 SetPixFormat(DC);
 HRC := wglCreateContext(DC);
 ReleaseDC(Handle, DC);
 wglMakeCurrent(DC, HRC);

// Z Buffer
 glEnable(GL_DEPTH_TEST);
 glDepthFunc(GL_LESS);
 glClearDepth(1.0);

// Back color
 glClearColor(0.0, 0.0, 1.0, 0.0);

// Texturing
 glEnable(GL_TEXTURE_2D);
 //LoadTexture(FILE_SKIN_MODEL, Skin);
 //LoadTexture(FILE_SKIN_WEAPON_MODEL, WeaponSkin);

// Culling
 glEnable(GL_CULL_FACE);
 glCullFace(GL_FRONT);
end;

// Finalize OpenGL
procedure FinalizeGL;
begin
// GL
 wglDeleteContext(HRC);
 wglMakeCurrent(0, 0);
 ReleaseDC(Handle, DC);
 DeleteDC(DC);
end;

// Setup a perspective
procedure SetPerspective(Width, Height: Integer);
var s: gldouble;
begin
 glViewport(0, 0, Width, Height);
 glMatrixMode(GL_PROJECTION);
 glLoadIdentity;
 //gluPerspective(45.0, Width / Height, 0.1, 256.0);
 s:=50.0;
 glOrtho(-s,s,-s,s,2*s,-2*s);
 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity;
end;

function inttostr(x: integer): string;
begin
str(x,result);
end;


// Window procedure: processing messges
function WindowProcedure(Window: hWnd; Message, wParam: Word; lParam: LongInt): LongInt; stdcall;
begin
 case Message of
  // Window create
  WM_CREATE:
   begin
    LoadModel(FILE_MODEL, Model);
 Next := Model.Cf + 1;  // один кадр буду смореть хоть и с глюками urrentFrame
 if Next >= model.Animations[1].EndFrame then Next := model.Animations[1].StartFrame;

    //Model.CurrentAnim :=3;
    //LoadModel(FILE_WEAPON_MODEL, WeaponModel);
   end;
  // Window resize
  WM_SIZE:
   begin
    SetPerspective(LOWORD(lParam),HIWORD(lParam));
   end;
  // Window close
  WM_CLOSE:
   begin
    FreeModel(Model);
    FreeModel(WeaponModel);

    PostQuitMessage(0);
    Exit;
   end;
  // Key down
  WM_KEYDOWN:
   begin
    Keys[wParam] := True;
   end;
  // Key up
  WM_KEYUP:
   begin
    Keys[wParam] := False;
   end;
  // Left mouse button
  WM_LBUTTONDOWN:
   begin
    //Model.CurrentAnim := (Model.CurrentAnim + 1) mod Model.NumAnimations;
    //Model.CurrentFrame := Model.Animations[Model.CurrentAnim].StartFrame;

 Next := Model.Cf + 1;  // один кадр буду смореть хоть и с глюками urrentFrame
 if Next >= model.Animations[1].EndFrame then Next := model.Animations[1].StartFrame;


 
    SetWindowText(Handle, PChar(TITLE + ' - ' + inttostr(Model.Cf)));//Model.Animations[Model.CurrentAnim].Name));
   end;
  // Left mouse button
  WM_RBUTTONDOWN:
   begin
    Fill := not Fill;
   end
 else Result := DefWindowProc(Window, Message, wParam, lParam);
 end;
end;

// Create the window
procedure CreateTheWindow(Width, Height: Integer);
var WindowClass: TWndClass;
    hInstance: HINST;
begin
 hInstance := GetModuleHandle(nil);

 ZeroMemory(@WindowClass, SizeOf(WindowClass));
 with WindowClass do
  begin
   Style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
   lpfnWndProc := @WindowProcedure;
   cbClsExtra := 0;
   cbWndExtra := 0;
   hInstance := hInstance;
   hIcon := LoadIcon(0, IDI_APPLICATION);
   hCursor := LoadCursor(0, IDC_ARROW);
   hbrBackground := GetStockObject(WHITE_BRUSH);
   lpszMenuName := '';
   lpszClassName := TITLE;
  end;

 RegisterClass(WindowClass);
 Handle := CreateWindowEx(WS_EX_APPWINDOW or WS_EX_WINDOWEDGE, TITLE, TITLE, WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_CLIPSIBLINGS, 0, 0, Width, Height, 0, 0, hInstance, nil);
 ShowWindow(Handle, SW_SHOW);

 InitializeGL;
 SetPerspective(WIDTH, HEIGHT);
end;

// Destroy the window
procedure DestroyTheWindow;
begin
 FinalizeGL;
 DestroyWindow(Handle);
 UnRegisterClass(TITLE, hInstance);
end;

// Main message loop for the application
function WinMain(hInstance: HINST; hPrevInstance: HINST; lpCmdLine: PChar; nCmdShow: Integer): Integer; stdcall;
var Msg : TMsg;
    Finished : Boolean;
begin
 Finished := False;

 while not Finished do
  begin
   if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
    begin
     if Msg.Message = WM_QUIT then Finished := True
     else
      begin
       TranslateMessage(msg);
       DispatchMessage(msg);
      end;
    end
   else
    begin
     ProcessKeys;
     Render; //
    end;
  end;

 Result := Msg.wParam;
end;

begin
 CreateTheWindow(WIDTH, HEIGHT);
 WinMain(hInstance, hPrevInst, CmdLine, CmdShow);
 DestroyTheWindow;
end.
