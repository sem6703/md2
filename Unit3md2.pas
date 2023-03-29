unit Unit3md2;
 {
 ссылка на игру


 }
interface

uses  opengl, math,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus;


{

 uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

}
type arrayi=array of integer;
type parray=^arrayi;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Timer1: TTimer;
    Panel2: TPanel;
    Panel1: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    MainMenu1: TMainMenu;
    here1: TMenuItem;
    header1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1Click(Sender: TObject);
    procedure here1Click(Sender: TObject);
    procedure header1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure boo(xx: integer);
    procedure push(x: parray; y: integer);
    procedure pop(x: parray; y: integer);
  end;
//*************************
type
  TMD2Header = record  //
    Magic,
    Version,
    SkinWidth,
    SkinHeight,
    FrameSize,
    NumSkins,
    NumVertices,
    NumTexCoords,
    NumTriangles,
    NumGLCommands,
    NumFrames,
    OffsetSkins,
    OffsetTexCoords,
    OffsetTriangles,
    OffsetFrames,
    OffsetGLCommands,
    OffsetEnd: Integer;
  end;
type
  TMD2TexCoord = record  //
    U, V: SmallInt;
  end;
 type
  TMD2Face = record  //
    VertexIndices, TextureIndices: array [0..2] of SmallInt;
  end;

type
  TMD2Triangle = record   //хз
    Vertex, Normal: array [0..2] of Single;
  end;


type
  TMD2Frame = record   // хз,
    Name: array [0..15] of Char;
    Vertices: array of TMD2Triangle;
  end;


type
  TMD2AliasTriangle = record   //вершина для фрейма
    Vertex: array [0..2] of Byte;
    LightNormalIndex: Byte;
  end;
type
  TMD2AliasFrame = record // фрейм
    Scale, Translate: array [0..2] of Single;
    Name: array [0..15] of Char;
    Vertices: array of TMD2AliasTriangle;
  end;

type
  TVector3 = record
    X, Y, Z: Single;
  end;

type
  TVector2 = record
    X, Y: Single;
  end;
type
  TFace = record   //
    VertexIndex,
    TexCoordIndex: array [0..2] of Integer;
  end;
type
  TAnimation = record //?
    Name: String;
    StartFrame,
    EndFrame: Integer;
  end;

type
  T3DObject = record //
    Name: String;
    NumVertex: Integer;
    Vertexes: array of TVector3;
  end;

type
  T3DModel = record //
    NumFaces,
    NumTexCoords,
    NumObjects,
    NumAnimations: Integer;

    //CurrentAnim, urrentFrame
    Cf: Integer;
    ElapsedTime, LastTime: Single;

    TexCoords: array of TVector2;
    Faces: array of TFace;
    Animations: array of TAnimation;
    Objects: array of T3DObject;
  end;


{const MHeader: TMD2Header=(
    Magic:1;
    Version:1;
    SkinWidth:1;
    SkinHeight:1;
    FrameSize:1;
    NumSkins:1;
    NumVertices:1;
    NumTexCoords:1;
    NumTriangles:1;
    NumGLCommands:1;
    NumFrames:1;
    OffsetSkins:1;
    OffsetTexCoords:1;
    OffsetTriangles:1;
    OffsetFrames:1;
    OffsetGLCommands:1;
    OffsetEnd: 1
    );
}



             //   VertexIndices, TextureIndices: array [0..2] of SmallInt;
//const MTriangles: array [0..0] of TMD2Face=((VertexIndices:(1,1,1); TextureIndices:(1,1,1)));












var
  Form1: TForm1;
  Model, WeaponModel: T3DModel;
  Fg: array[0..200]of TMD2AliasFrame;
  key: array[byte] of byte;
  gcu: integer=7;
  mot: array of arrayi;//array of integer;
  medx,medz: array of tpoint;
  ika: integer=1; // номер кадра
  pis: single =0.0;

  aj: array of arrayi;
  dot: array of boolean;
  d: string='';
  //swat: array[0..2] of integer=(277, 257, 250);
 //        swat: array[0..9] of integer=(295, 296, 290, 293, 284, 285, 284, 285, 291, 283);
 {
 swat: array[0..43] of integer=(295, 296, 293, 290, 292, 284, 291, 285, 294, 288, 283, 258, 256,
 296, 292, 291, 288, 256,80, 237, 84, 255, 78, 91, 92, 85, 87, 89,82, 81, 83, 77, 90, 88, 237, 80, 24, 272,
 41, 51, 37, 23, 86 ,79
 //33, 32, 30, 53, 14, 56, 29, 27, 31 //щека
 );
  }
 // swat: array[0..0] of integer= (11);
 // swat: array of integer;



 part: array of array of TVector3;   // центры частей
 mar: integer=0; // часть с центром
 ale: array of single; // мастабирую части
 grop: array of integer;// принадлежность частей групам
 goy: integer;// група
 c3d: array of array of tvector3;
 hdr: TMD2Header;

implementation

{$R *.dfm}
uses female;


procedure fn_key; // бочкообразная трансформация модели
var i: integer;
begin
for i:=0 to 255 do
  begin
    case i of
      0..31:key[i]:=0;
      32..95:key[i]:=i-31;
      96..127:key[i]:=64+(i-96)*2;
      128: key[i]:=128;
      129..255:key[i]:=255-key[255-i];
    end;
  end;
end;





procedure LoadModel(Filename: String; var Model: T3DModel);
var F: File;
    i,j,k: Integer;
    Header: TMD2Header;
    TexCoords: array of TMD2TexCoord;
    Triangles: array of TMD2Face;
    Frames: array of TMD2Frame;
    Frame: TMD2AliasFrame;
    CurrentFrame: T3DObject;
    FrameNum: Integer;
    Animation: TAnimation;
    Name, LastName: String;
begin
// Load model form file
 Assign(F, Filename);
 Reset(F, 1);
// Header
 BlockRead(F, Header, SizeOf(TMD2Header));
 if Header.Version <> 8 then Exit;
// Texture coords
 Seek(F, Header.OffsetTexCoords);
 SetLength(TexCoords, Header.NumTexCoords);
 BlockRead(F, TexCoords[0], SizeOf(TMD2TexCoord) * Header.NumTexCoords);
// Triangles
 Seek(F, Header.OffsetTriangles);
 SetLength(Triangles, Header.NumTriangles);
 BlockRead(F, Triangles[0], SizeOf(TMD2Face) * Header.NumTriangles);
// Frames
 SetLength(Frames, Header.NumFrames);
 for i := 0 to Header.NumFrames - 1 do
  begin
   Seek(F, Header.OffsetFrames+i*(SizeOf(Frame.Scale)+SizeOf(Frame.Translate)+SizeOf(Frame.Name)+SizeOf(TMD2AliasTriangle) * Header.NumVertices));

   SetLength(Frame.Vertices, Header.NumVertices);
   BlockRead(F, Frame.Scale, SizeOf(Frame.Scale));
   BlockRead(F, Frame.Translate, SizeOf(Frame.Translate));
   BlockRead(F, Frame.Name, SizeOf(Frame.Name));
   BlockRead(F, Frame.Vertices[0], SizeOf(TMD2AliasTriangle) * Header.NumVertices);
   SetLength(Frames[i].Vertices, Header.NumVertices);
   StrCopy(Frames[i].Name, Frame.Name);

   hdr:=header;

  for j := 4440 to Header.NumVertices - 1 do  // делаю бочку
    begin  // уродую    *****************************************************************
      for k:=0 to 0 do Frame.Vertices[j].Vertex[k]:=key[Frame.Vertices[j].Vertex[k]];
      Frame.Vertices[j].Vertex[1]:=key[Frame.Vertices[j].Vertex[1]];
      //Frame.Vertices[j].Vertex[2]:=key[Frame.Vertices[j].Vertex[2]];
    end;

   fg[i]:=frame;
   for j := 0 to Header.NumVertices - 1 do
    begin
     Frames[i].Vertices[j].Vertex[0] := Frame.Vertices[j].Vertex[0] * Frame.Scale[0] + Frame.Translate[0];
     Frames[i].Vertices[j].Vertex[2] := -1 * (Frame.Vertices[j].Vertex[1] * Frame.Scale[1] + Frame.Translate[1]);
     Frames[i].Vertices[j].Vertex[1] := Frame.Vertices[j].Vertex[2] * Frame.Scale[2] + Frame.Translate[2];
    end;
    //***********************
  end;
 Close(F);//
//************************

 Model.NumObjects := Header.NumFrames;
 SetLength(Model.Objects, Model.NumObjects);
 for i := 0 to Model.NumObjects - 1 do
  begin
   CurrentFrame.Name := Frames[i].Name;
   CurrentFrame.NumVertex := Header.NumVertices;
   SetLength(CurrentFrame.Vertexes, CurrentFrame.NumVertex);

   for j := 0 to CurrentFrame.NumVertex - 1 do
    begin
     CurrentFrame.Vertexes[j].X := Frames[i].Vertices[j].Vertex[0];
     CurrentFrame.Vertexes[j].Y := Frames[i].Vertices[j].Vertex[1];
     CurrentFrame.Vertexes[j].Z := Frames[i].Vertices[j].Vertex[2];
    end;
   Model.Objects[i] := CurrentFrame;
  end;
end;


procedure tform1.boo(xx: integer);  // отрисовка
  var i,j,k: integer;
  sx,dx,ex: single;
  sy,dy,ey: single;
  sz,dz,ez: single;
  cx,cy,cz: single;
  ex2: integer;
  a1: array of tpoint;
  x3,y3:integer;
  ii:real;
  s: string;
  v3: tvector3;


  function fnf: integer;    // посчитал запятые
  var i: integer; //  ,j,k
  begin
    result:=-1;
    for i:=1 to length(d) do
      if d[i]=',' then inc(result);
  end;
begin
goy:=grop[mar];

setlength(medx,high(model.objects[0].vertexes)+1);

j:=xx;     //ищу минимаксы  (sx,dx,sy,dy,sz,dz)
//****************************
sx:=model.objects[j].vertexes[0].x;
dx:=model.objects[j].vertexes[0].x;
for i:=0 to  high(model.objects[0].vertexes) do
  begin
    if model.objects[j].vertexes[i].x>sx then sx:=model.objects[j].vertexes[i].x;
    if model.objects[j].vertexes[i].x<dx then dx:=model.objects[j].vertexes[i].x;
  end;
  //************************
sy:=model.objects[j].vertexes[0].y;
dy:=model.objects[j].vertexes[0].y;
for i:=0 to  high(model.objects[0].vertexes) do
  begin
    if model.objects[j].vertexes[i].y>sy then sy:=model.objects[j].vertexes[i].y;
    if model.objects[j].vertexes[i].y<dy then dy:=model.objects[j].vertexes[i].y;
  end;
  //****************************
sz:=model.objects[j].vertexes[0].z;
dz:=model.objects[j].vertexes[0].z;
for i:=0 to  high(model.objects[0].vertexes) do
  begin
    if model.objects[j].vertexes[i].z>sz then sz:=model.objects[j].vertexes[i].z;
    if model.objects[j].vertexes[i].z<dz then dz:=model.objects[j].vertexes[i].z;
  end;
//****************
k:=9;  // коэф увеличения
//****************
ex:=abs(sx-dx); ex2:=round(abs(sx-dx))*k div 2;
ey:=abs(sy-dy);
ez:=abs(sz-dz);
//*********************
//     время рисовать   **********************************************************
with image1.Canvas do
begin
  brush.Color:=clwhite;
  fillrect(cliprect);
  brush.Color:=claqua;
  fillrect(rect(0,0,round(ex*k),round(ey*k)));
  brush.Color:=clsilver;
  fillrect(rect(0,0,-round(dx*k),-round(dy*k)));
  brush.Color:=clblue;
  for i:=0 to high(model.objects[j].vertexes) do
//*********************  не вошедшие
    begin
      cx:=model.objects[j].vertexes[i].x-dx;
      cy:=model.objects[j].vertexes[i].y-dy;
      cz:=model.objects[j].vertexes[i].z-dz;
      x3:=round(cx*k);
     //     /центральная       /сумарный угол палки    /длина палки
     // x3:=ex2+               round(cos()*           sqrt(sqr(cx-ex/2)+sqr(cz-ez/2)));

    // ii:=cos(arctan2(cx-ex/2,cz-ez/2));
    //if hypot(cz-ez/2,cx-ex/2)  <> sqrt(sqr(cx-ex/2)+sqr(cz-ez/2)) then
     //  showmessage('ty'#13#10+format('%f %f',[ hypot(cz-ez/2,cx-ex/2),sqrt(sqr(cx-ex/2)+sqr(cz-ez/2))]));
     // x3:=ex2+  round(k*cos(pis+arctan2(cz-ez/2,cx-ex/2))*sqrt(sqr(cx-ex/2)+sqr(cz-ez/2)));
      x3:=ex2+  round(k*cos(pis+arctan2(cz-ez/2,cx-ex/2))*hypot(cz-ez/2,cx-ex/2));
      y3:=round((ey-cy)*k);
      if dot[i] then  // верши не вошедшие в части
        fillrect(rect(x3-2,y3-2,x3+2,y3+2));

      medx[i]:=point(x3,y3);  // проекция
    end;
//******************************
brush.style:=bsclear;
pen.Color:=clblack; pen.Width:=1;
polygon([medx[gcu],point(200,200),point(200,8),point(8,8)]); // черная указка
//*************************
for j:=0 to high(mot) do   // соединение выбраных вершей
  begin
    setlength(a1,high(mot[j])+1);
    for i:=0 to high(a1) do
      begin
        a1[i]:=medx[mot[j][i]];
      end;
    pen.Color:=clred; pen.Width:=3;
    polygon(a1);////
  end;
//***************************
for j:=0 to high(aj) do     // перебор частей и отрисовка
  begin
    setlength(a1,high(aj[j])+1);
    for i:=0 to high(a1) do
        begin
          v3:=part[j][ika];
          cx:=v3.x-dx;
          cy:=v3.y-dy;
          cz:=v3.z-dz;
          //x3:=ex2+  round(k*cos(pis+arctan2(cz-ez/2,cx-ex/2))*sqrt(sqr(cx-ex/2)+sqr(cz-ez/2)));
          x3:=ex2+  round(k*cos(pis+arctan2(cz-ez/2,cx-ex/2))*hypot(cz-ez/2,cx-ex/2));
          y3:=round((ey-cy)*k);
          a1[i]:=point(round(x3+ale[j]*(medx[aj[j][i]].x-x3)), //
                       round(y3+ale[j]*(medx[aj[j][i]].y-y3)));
        end;
    pen.Color:=clolive; pen.Width:=1;
         pen.Width:=6;
    if goy=grop[j] then
      begin
        pen.Color:=clfuchsia; pen.Width:=2; //
      end;
    polygon(a1);////
  end;
//**************************centeres of parts
v3:=part[mar][ika];// у выбраной группа рисую центр
      cx:=v3.x-dx;
      cy:=v3.y-dy;
      cz:=v3.z-dz;
      x3:=ex2+  round(k*cos(pis+arctan2(cz-ez/2,cx-ex/2))*sqrt(sqr(cx-ex/2)+sqr(cz-ez/2)));
      y3:=round((ey-cy)*k);
      with image1.Canvas do
        begin
          brush.Color:=clfuchsia;  /// центр части
          fillrect(rect(x3-4,y3-4,x3+4,y3+4));
        end;
end;
end;


function xota(x: array of integer; y: integer): TVector3; //центр части
var i: integer;    min1,max1: single;     //
begin
min1:= model.Objects[y].vertexes[x[0]].x; max1:=min1;
for i:=0 to high(x) do
  begin
    if min1>model.Objects[y].vertexes[x[i]].x then min1:=model.Objects[y].vertexes[x[i]].x;
    if max1<model.Objects[y].vertexes[x[i]].x then max1:=model.Objects[y].vertexes[x[i]].x;
  end;
result.x:=min1+(max1-min1)/2;
//*****************
min1:= model.Objects[y].vertexes[x[0]].y; max1:=min1;
for i:=0 to high(x) do
  begin
    if min1>model.Objects[y].vertexes[x[i]].y then min1:=model.Objects[y].vertexes[x[i]].y;
    if max1<model.Objects[y].vertexes[x[i]].y then max1:=model.Objects[y].vertexes[x[i]].y;
  end;
result.y:=min1+(max1-min1)/2;
//***********************
min1:= model.Objects[y].vertexes[x[0]].z;  max1:=min1;
for i:=0 to high(x) do
  begin
    if min1>model.Objects[y].vertexes[x[i]].z then min1:=model.Objects[y].vertexes[x[i]].z;
    if max1<model.Objects[y].vertexes[x[i]].z then max1:=model.Objects[y].vertexes[x[i]].z;
  end;
result.z:=min1+(max1-min1)/2;
end;


procedure waq(x: array of integer;y: boolean);// составляем часть из вершин
var i,j,k: integer;
begin
setlength(aj,high(aj)+2);
setlength(aj[high(aj)],high(x)+1);
for i:=0 to high(x) do aj[high(aj)][i]:=x[i];
if y then for i:=0 to high(x) do dot[x[i]]:=false;
//******************
setlength(part,high(part)+2);
setlength(ale,high(ale)+2);
ale[high(ale)]:=1.0;//0.5;//
setlength(part[high(part)],high(model.objects)+1);  //1);//
for i:=0 to high(part[high(part)]) do //0 do//
  begin
    part[high(part)][i]:=xota(x,i);
  end;
//*********************
setlength(grop,high(grop)+2);
grop[high(grop)]:=high(grop);
end;


procedure grupe(x: array of integer); //  по идее несколько частей обьедин в группу
var i,j,k: integer; min1: integer; v3: tvector3; min2,max2: single;
begin
min1:=grop[x[0]];    // поиск минимума
for i:=0 to high(x) do
  if min1>grop[x[i]] then min1:=grop[x[i]];
for i:=0 to high(x) do grop[x[i]]:=min1;
//v3:=
for j:=0 to high(part[x[0]]) do  // поиск центра ?  какого?
  begin
    min2:= part[x[0]][j].x; max2:=min2;
    for i:=0 to high(x) do     // поиск мини макса
      begin
        if min2>part[x[i]][j].x then min2:=part[x[i]][j].x;
        if max2<part[x[i]][j].x then max2:=part[x[i]][j].x;
      end;
    v3.x:=min2+(max2-min2)/2;
    //*********************
    min2:= part[x[0]][j].y; max2:=min2;
    for i:=0 to high(x) do
      begin
        if min2>part[x[i]][j].y then min2:=part[x[i]][j].y;
        if max2<part[x[i]][j].y then max2:=part[x[i]][j].y;
      end;
    v3.y:=min2+(max2-min2)/2;

    //**********************
    min2:= part[x[0]][j].z; max2:=min2;
    for i:=0 to high(x) do
      begin
        if min2>part[x[i]][j].z then min2:=part[x[i]][j].z;
        if max2<part[x[i]][j].z then max2:=part[x[i]][j].z;
      end;
    v3.z:=min2+(max2-min2)/2;
    //**************************
    for k:=0 to high(x) do part[x[k]][j]:=v3; // центр найден ?
  end;
end;


procedure grupe2(x: array of integer; y: single); // групирует масшабит
var i,j,k: integer;
begin
  grupe(x);
  for i:=0 to high(x) do ale[x[i]]:=y;
end;


procedure TForm1.FormCreate(Sender: TObject);
var i,j,k: integer;
a: array[byte]of integer;
begin
//*************************
  decimalseparator:='.';

//********************
  setlength(mot,1);//
  with image2.Canvas do
    begin
      brush.Color:=clnavy;
      fillrect(cliprect);
    end;
  for i:=0 to 255 do a[i]:=0;
  fn_key; // ключ подстановки
//  LoadModel('base\female\tris.md2', Model);
//  LoadModel('base\fff\tris.md2', Model);
  LoadModel('base\female — копия\tris.md2', Model);
//  LoadModel('base\female\tris.md2', Model);

//*********************
//setlength(dot,high(model.objects)+2);
setlength(dot,high(model.objects[0].vertexes)+1);
for i:=0 to high(dot) do dot[i]:=true;  //false;//  отображаемые вершины
//for i:=0 to high(swat) do dot[swat[i]]:=false;
//dot[296]:=dot[296];
//*********************!"
waq([191,190,184,179,186,176],1=1);// лях1      0
waq([125,130,127,131,132,142],1=1);//   лях2     1
waq([177,180,175,121,126,124,129,128,136,141,189,183,182],1=1); // гузно      2
waq([172, 120, 133, 225, 185],1=1);// лобок             3
waq([44, 55, 26, 28, 39],1=1);// лоб                  4
waq([105, 94, 95, 96, 93],1=1);// кисть лев             5
waq([6, 8, 20, 15, 1, 2, 0, 10, 7, 9, 5],1=1);// хвост     6
waq([102, 107, 103, 100, 98],1=1);// фак                   7
 waq([308, 297, 299, 300, 298],1=1);//запястье 1           8
waq([241, 264, 140, 119, 230, 238],1=1);// спина             9
waq([158, 145, 143, 155, 157, 151, 149],1=1);// колено        10
waq([38,40],1=1);// nose                                     11
waq([200, 208, 205, 196, 194, 209, 202],1=1);// колено 2        12
waq([213, 212, 210, 199],1=1);// пятка1                        13
waq([159, 162, 146, 161],1=1);                              //    14
waq([70, 72, 71, 69],1=1);//носок                               15
waq([111, 112, 108, 109],1=1);//носок2                          16
waq([206, 115, 116, 216],1=1);//лодыжка                        17
waq([163, 154, 76, 75],1=1);//логика2                         18
waq([156, 148, 153],1=1);                                  //  19
waq([207, 197, 203],1=1); //икра                            20
 waq([203, 201, 204, 195],1=1);// подколен                21

waq([174, 135, 117, 123, 134, 178],1=1);// пояс          22
waq([240,235],1=1);//  грудина                            23
waq([233,231,232],1=1);// сосок                            24
waq([267,266,268],1=1);//  сосок                           25
 waq([235, 234, 227, 229, 223, 240],1=1);// сиси             26
waq([240, 259, 265, 173, 269, 235],1=1);//сиси               27
waq([170, 169, 192, 168],1=1); // клет                      28
waq([171, 118,261, 193],1=1);// ребро                       29
//зад
waq([181, 188],1=1);                         //   30
waq([188, 187],1=1);                          //  31
 waq([187, 122],1=1);                         //  32
waq([122, 138],1=1);                          //  33
waq([138, 139],1=1);                          //  34
waq([139, 137],1=1);                          //  35
waq([153, 144, 152, 150],1=1);//подколен             36
waq([65, 59, 58, 57, 42, 25, 22, 52, 54],1=1);//затылок     37
  waq([36, 35, 49, 34],1=1);//рот                            38
waq([33, 32, 30, 53, 14, 56, 29, 27, 31],1=1);//щека1        39
waq([47, 50, 48, 43, 45, 66, 12, 61, 46],1=1);//щека2        40
 waq([215, 114, 113],1=1);//ьот                      41
 waq([166, 167, 164],1=1);//ище                      42
waq([67, 64, 63, 60],1=1);        //                  43
 waq([86, 80, 84, 78, 79],1=1);//плеч1                 44
 waq([287, 282, 281, 242, 289, 286],1=1);//плеч2        45
 waq([51, 41, 24, 23, 37],1=1);//ворот                  46
waq([81, 82, 85, 89, 88, 87],1=1);//локо               47
waq([92, 91, 90],1=1);//рука                            48
 waq([83, 77],1=1);//бицуха                               49
 waq([294, 296, 295],1=1);//рука2                          50
 waq([283, 288],1=1);//биц                                 51
waq([285, 284, 290, 293, 292, 291],1=1);//локо              52
//if  dot[194] then showmessage(inttostr(i));
 waq([263, 262, 239, 226, 228],1=1);//диафраг              53
 waq([1, 11],1=1);//волос                                   54
 waq([16, 21, 6, 4, 19, 8,18,3],1=1);//узел                55
waq([17, 62,60],1=1);//гвозд                                56
waq([276, 275, 278, 277],1=1); //top                        57
waq([244, 248, 247, 251],1=1);//top2                         58
waq([254, 222, 243],1=1);//bret                               59
waq([272, 279, 260],1=1);//bret2                             60

  waq([255, 249, 246],1=1);//ключицы                          61
  waq([250, 273, 280],1=1); //                                62
 waq([224, 221, 236, 237],1=1);//хз                           63
 waq([256, 258, 270, 271],1=1); //                            64


//**** список обьединнений и увечий
  grupe2([24,25,26,27], 1.3);  /// сиськи
 //ale[24]:=1.0; ale[25]:=1.0;  ale[26]:=1.0; ale[27]:=1.0;
  grupe2([30,31,32,33,34,35,2], 0.6);  ///  3.0    задница
  grupe2([4,6,11,37,38,39,40,55,56], 1.0);  // узел


//*********************
  boo(ika);   // отрисовка
end;


procedure ozo(x:integer; y: single); //  масштабирую в у раз
var i,g: integer; //j,k
begin
  g:=grop[mar];
  for i:=0 to high(grop) do
    if grop[i]=g then
      ale[i]:=ale[i]+y;
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var b: boolean;  i,j,k: integer;
begin
j:=ika;
  case key of
  vk_up: begin gcu:=gcu+1 end;
  vk_down: begin gcu:=gcu-1 end;
  vk_left:dec(ika);
  vk_right:inc(ika);
  // зацени фиктивный вызов маусдауна image2.onMousedown(nil,mbLeft,[],0,0);
  vk_numpad1:image2.onMousedown(nil,mbLeft,[],0,0);
  vk_numpad7:dec(mar); // курсор лдя part
  vk_numpad9:inc(mar);
  end;

  if ika<0 then ika:= high(model.objects);
  if ika>high(model.objects) then ika:=0;

  if mar<0 then mar:= high(part);
  if mar>high(part) then mar:=0;

  if gcu<0 then gcu:=high(model.objects[0].vertexes);
  if gcu>high(model.objects[0].vertexes) then gcu:=0;
  //*******************
  form1.caption:=inttostr(ika);
  //*************************
  if key=vk_numpad0 then  // доб/удал в mot gsu
    begin
      b:=true;
      for i:=0 to high(mot[high(mot)]) do if gcu=mot[high(mot)][i] then b:=false;
      if b then push(@mot[high(mot)],gcu) else pop(@mot[high(mot)],gcu);
    end;
  if key=vk_space then // доб в mot новую ...
    begin
      setlength(mot,high(mot)+2);
      setlength(mot[high(mot)],1);
      mot[high(mot)][0]:=mot[high(mot)-1][high(mot[high(mot)-1])];
      setlength(mot[high(mot)-1],high(mot[high(mot)-1]));
    end;
  case key of
    vk_numpad8:ozo(mar,0.1);//ale[mar]:=ale[mar]+0.1;
    vk_numpad5:ozo(mar,-0.1);//ale[mar]:=ale[mar]-0.1;
  end;

  boo(ika);
end;




procedure tform1.push(x: parray; y: integer);
var i,j,k: integer;
begin
  setlength(x^,high(x^)+2);
  x^[high(x^)]:=y;
end;


procedure tform1.pop(x: parray; y: integer);
var i,j,k: integer;
begin
  if high(x^)<0 then exit;
  for i:=0 to high(x^)-1 do if x^[i]=y then begin x^[i]:=x^[i+1]; x^[i+1]:=y end;
  x^[high(x^)]:=y;
  setlength(x^,high(x^));
end;


procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;  // выбор вертекса
  Shift: TShiftState; X, Y: Integer);
var i,j,k: integer; r,e: real;
begin
	k:=gcu;
	r:=sqr(medx[k].x-x)+sqr(medx[k].y-y);
	for i:=0 to high(medx) do
	// if dot[i] then
		begin
			j:=(i+gcu) mod (high(medx)+1);
			e:=sqr(medx[j].x-x)+sqr(medx[j].y-y);
			if e<=r then begin r:=e; k:=j  end;
		end;
	form1.Caption:=format('%d [%d]',[k,medx[k].y]);
	gcu:=k;

	if mbright in [button] then  // пкм делает.... строку из номеров вершин?  бездумное щелкание по вершинам логируется в строку
		begin
			d:=d+format('%d, ',[k]);
		end;
	boo(ika);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
pis:=pis+pi/180;
if pis>2*pi then pis:=0;
boo(ika);   // отрисовка
end;


procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton; // вращение вкл/выкл
  Shift: TShiftState; X, Y: Integer);
var b: boolean;
begin
b:=timer1.Enabled;
timer1.Enabled:=not b;
end;


procedure TForm1.Panel1Click(Sender: TObject);    // SAVE
var Filenamein: string;//='base\female\trisin.md2'; // 'base\female — копия\tris.md2'
var Filenameout: string;//='base\female\tris.md2';
var i,j,k: integer; min1,max1: single;

  sx,dx,ex: single;
  sy,dy,ey: single;
  sz,dz,ez: single;
  cx,cy,cz: single;
  ex2: integer;
    a1: array of tpoint;
  x3,y3:integer;
  r:real;
  s: string;
  v3, v4: tvector3;
  ver: integer;
  ii,jj,kk: integer;
  kd: integer; // cadr
  kf: integer; // koefficiente
  minv,maxv: single;
//*********************

  F1,f2: File;
    Header: TMD2Header;
    TexCoords: array of TMD2TexCoord;
    Triangles: array of TMD2Face;
    Frames: array of TMD2Frame;
    Frame: TMD2AliasFrame;

    CurrentFrame: T3DObject;

    FrameNum: Integer;
    Animation: TAnimation;
    Name, LastName: String;



begin
//************************
//************************
Filenamein:='base\female\trisin.md2'; // 'base\female — копия\tris.md2'
Filenameout:='base\female\tris.md2';   // пишется сюда
// Load model form file

 Assignfile(F1, Filenamein);  //[Error] Unit2md2.pas(1011): Incompatible types: 'TPersistent' and 'file'
Reset(F1, 1);

// Header
 BlockRead(F1, Header, SizeOf(TMD2Header));
 if Header.Version <> 8 then Exit;

// Texture coords
 Seek(F1, Header.OffsetTexCoords);
 SetLength(TexCoords, Header.NumTexCoords);
 BlockRead(F1, TexCoords[0], SizeOf(TMD2TexCoord) * Header.NumTexCoords);

// Triangles
 Seek(F1, Header.OffsetTriangles);
 SetLength(Triangles, Header.NumTriangles);
 BlockRead(F1, Triangles[0], SizeOf(TMD2Face) * Header.NumTriangles);

// Frames
 Seek(F1, Header.OffsetFrames);
 SetLength(Frames, Header.NumFrames);
 for i := 0 to Header.NumFrames - 1 do
  begin
   Seek(F1, Header.OffsetFrames+i*(SizeOf(Frame.Scale)+SizeOf(Frame.Translate)+SizeOf(Frame.Name)+SizeOf(TMD2AliasTriangle) * Header.NumVertices));

   SetLength(Frame.Vertices, Header.NumVertices);
   BlockRead(F1, Frame.Scale, SizeOf(Frame.Scale));
   BlockRead(F1, Frame.Translate, SizeOf(Frame.Translate));
   BlockRead(F1, Frame.Name, SizeOf(Frame.Name));
   BlockRead(F1, Frame.Vertices[0], SizeOf(TMD2AliasTriangle) * Header.NumVertices);

   SetLength(Frames[i].Vertices, Header.NumVertices);
   StrCopy(Frames[i].Name, Frame.Name);
   fg[i]:=frame;
   end;
 Closefile(F1);//

//*************************************************
setlength(c3d,high(model.objects)+1);
for i:=0 to high(c3d) do
  setlength(c3d[i],high(model.objects[i].vertexes)+1);
for kd:=0 to high(model.objects) do   // номер кадра
  begin
    sx:=model.objects[kd].vertexes[0].x;
    dx:=model.objects[kd].vertexes[0].x;
    for k:=0 to  high(model.objects[0].vertexes) do
      begin
        if model.objects[kd].vertexes[k].x>sx then sx:=model.objects[kd].vertexes[k].x;
        if model.objects[kd].vertexes[k].x<dx then dx:=model.objects[kd].vertexes[k].x;
      end;
    sy:=model.objects[kd].vertexes[0].y;
    dy:=model.objects[kd].vertexes[0].y;
    for k:=0 to  high(model.objects[0].vertexes) do
      begin
        if model.objects[kd].vertexes[k].y>sy then sy:=model.objects[kd].vertexes[k].y;
        if model.objects[kd].vertexes[k].y<dy then dy:=model.objects[kd].vertexes[k].y;
      end;
    sz:=model.objects[kd].vertexes[0].z;
    dz:=model.objects[kd].vertexes[0].z;
    for k:=0 to  high(model.objects[0].vertexes) do
      begin
        if model.objects[kd].vertexes[k].z>sz then sz:=model.objects[kd].vertexes[k].z;
        if model.objects[kd].vertexes[k].z<dz then dz:=model.objects[kd].vertexes[k].z;
      end;
    //****************
    kf:=9;//1;//9;  // коэф увеличения
    //****************
    ex:=abs(sx-dx);
    ey:=abs(sy-dy);
    ez:=abs(sz-dz);

  for ver:=0 to high(c3d[kd]) do//номер вершины
    begin
        cx:=model.objects[kd].vertexes[ver].x-dx;
        cy:=model.objects[kd].vertexes[ver].y-dy;
        cz:=model.objects[kd].vertexes[ver].z-dz;

        v3.X:=cx;
        v3.Y:=cy;
        v3.Z:=cz;
        c3d[kd][ver]:= v3;
    end;

// найти центры фигур
(*       *)
  for ii:=0 to high(aj) do // перебор частей  увеличение их на величину
    begin
      v3:=part[ii][kd];//ii-part  i-cadr

      v3.X:=v3.X-dx;
      v3.Y:=v3.Y-dy;
      v3.Z:=v3.Z-dz;
      if ale[ii]<1.0 then
      for jj:=0 to high(aj[ii]) do  // вершины
        begin
          v4:=c3d[kd][aj[ii][jj]];
          v4.X:=v3.x+(v4.X-v3.X)*ale[ii];  // применяю мосштаб части
          v4.y:=v3.y+(v4.y-v3.y)*ale[ii];
          v4.z:=v3.z+(v4.z-v3.z)*ale[ii];
          c3d[kd][aj[ii][jj]]:=v4;
        end;
    end;
    
//
 // теперь поступаем с выступающими вершинами. может обкарнать просто их?
 (*      *)
  for ver:=0 to high(c3d[kd]) do
    begin
      if (c3d[kd][ver].x<0)then c3d[kd][ver].x:=0;
      if (c3d[kd][ver].y<0)then c3d[kd][ver].y:=0;
      if (c3d[kd][ver].z<0)then c3d[kd][ver].z:=0;

      if (c3d[kd][ver].x>ex)then c3d[kd][ver].x:=ex;
      if (c3d[kd][ver].y>ey)then c3d[kd][ver].y:=ey;
      if (c3d[kd][ver].z>ez)then c3d[kd][ver].z:=ez;
    end;
    
//

      (*   перевод в формат для записи в файл     *)
    
    j:=128;
    for ver:=0 to high(c3d[kd]) do
      begin
        v3:=c3d[kd][ver];
        r:=(ex/255);
        fg[kd].Vertices[ver].vertex[0]:=round(v3.X / r);
        r:=(ey/255);
        fg[kd].Vertices[ver].vertex[2]:=round(v3.y / r);
        r:=(ez/255);
        fg[kd].Vertices[ver].vertex[1]:=255-round(v3.z / r);
      end;




//****
  end;// kd

//*********************************************

//***********************************************
 // Save model to file
 Assignfile(F2, Filenameout);
 Reset(F2, 1);
 for i:=0 to Header.NumFrames - 1 do
   begin
   Seek(F2, Header.OffsetFrames+i*(SizeOf(Frame.Scale)+SizeOf(Frame.Translate)+SizeOf(Frame.Name)+SizeOf(TMD2AliasTriangle) * Header.NumVertices));
   BlockWrite(F2, fg[i].Scale, SizeOf(Frame.Scale));
   BlockWrite(F2, fg[i].Translate, SizeOf(Frame.Translate));
   BlockWrite(F2, fg[i].Name, SizeOf(Frame.Name));
   BlockWrite(F2, fg[i].Vertices[0], SizeOf(TMD2AliasTriangle) * Header.NumVertices);
   end;
 Closefile(F2);//
//************************
showmessage('ну блять за ебись записано в'#13#10'base\female\tris.md2'); // пишется сюда
end;


procedure TForm1.here1Click(Sender: TObject);
begin
showmessage(paramstr(0));
end;

procedure TForm1.header1Click(Sender: TObject);
begin
memo2.Clear;
memo2.Font.Size:=11;
memo2.lines.Add(format('%s%s%s%s',
[
chr((hdr.Magic and $ff) shr 0),
chr((hdr.Magic and $ff00) shr 8),
chr((hdr.Magic and $ff0000) shr 16),
chr((hdr.Magic and $ff000000) shr 24)
]));
memo2.lines.Add(format('%d - версия',[hdr.Version]));
memo2.lines.Add(format('%d - длина скина',[hdr.SkinWidth]));
memo2.lines.Add(format('%d - высота скина',[hdr.SkinHeight]));
memo2.lines.Add(format('%d - размер кадра',[hdr.FrameSize]));
memo2.lines.Add(format('%d - колво скинов',[hdr.NumSkins]));
memo2.lines.Add(format('%d - колво вершин',[hdr.NumVertices]));
memo2.lines.Add(format('%d - колво тексткоорд',[hdr.NumTexCoords]));
memo2.lines.Add(format('%d - колво треугов',[hdr.NumTriangles]));
memo2.lines.Add(format('%d - колво GL',[hdr.NumGLCommands]));
memo2.lines.Add(format('%d - колво кадров',[hdr.NumFrames]));

memo2.lines.Add(format('%d - смещение скинов',[hdr.OffsetSkins]));
memo2.lines.Add(format('%d - смещение тексткоорд',[hdr.OffsetTexCoords]));
memo2.lines.Add(format('%d - смещ треугов',[hdr.OffsetTriangles]));
memo2.lines.Add(format('%d - смещ кадров',[hdr.OffsetFrames]));
memo2.lines.Add(format('%d - смещение GL',[hdr.OffsetGLCommands]));
memo2.lines.Add(format('%d - смещ конца',[hdr.OffsetEnd]));
end;




   {
    Magic,
    Version,
    SkinWidth,
    SkinHeight,
    FrameSize,
    NumSkins,
    NumVertices,
    NumTexCoords,
    NumTriangles,
    NumGLCommands,
    NumFrames,
    OffsetSkins,
    OffsetTexCoords,
    OffsetTriangles,
    OffsetFrames,
    OffsetGLCommands,
    OffsetEnd: Integer;
    }

end.
{
Num1 - вращение
Num7 - 
Num9 - next figure
Num5 - down size
Num8 - up size
Up - prev vertex
Down - next vertex
Left - prev cadr
Right - next cadr


}
