unit MD2;

///////////////////////////////////////
//   Unit : MD2
//   Date : 20/04/2002
// Author : Vashchaev 'viv' Ivan
// e-Mail : ivanv@softhome.net
///////////////////////////////////////

interface

uses  Messages, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus, ExtDlgs, ComCtrls,


     Windows, SysUtils, OpenGL;

const
  MD2_MAX_TRIANGLES = 4096;
  MD2_MAX_VERTICES = 2048;
  MD2_MAX_TEXCOORDS = 2048;
  MD2_MAX_FRAMES = 512;
  MD2_MAX_SKINS	= 32;
  MD2_MAX_FRAMESIZE = (MD2_MAX_VERTICES * 4 + 128);
  ANIMATION_SPEED = 1.0;

type
  TMD2Header = record  //заголовок
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
  TMD2AliasTriangle = record   //вершина для фрейма
    Vertex: array [0..2] of Byte;
    LightNormalIndex: Byte;
  end;

type
  TMD2Triangle = record   //хз
    Vertex, Normal: array [0..2] of Single;
  end;

type
  TMD2Face = record  //треугольник
    VertexIndices, TextureIndices: array [0..2] of SmallInt;
  end;

type
  TMD2TexCoord = record  //точка текстуры
    U, V: SmallInt;
  end;

type
  TMD2AliasFrame = record // фрейм
    Scale, Translate: array [0..2] of Single;
    Name: array [0..15] of Char;
    Vertices: array of TMD2AliasTriangle;
  end;

type
  TMD2Frame = record   // хз,
    Name: array [0..15] of Char;
    Vertices: array of TMD2Triangle;
  end;

///////////////////////////////////////////////
type
  TVector3 = record
    X, Y, Z: Single;
  end;

type
  TVector2 = record
    X, Y: Single;
  end;

type
  TFace = record   //треугольники.  почемуто integer а не smallint
    VertexIndex,
    TexCoordIndex: array [0..2] of Integer;
  end;

type
  TAnimation = record //похоже получается из заголовков фреймов
    Name: String;
    StartFrame,
    EndFrame: Integer;
  end;

type
  T3DObject = record //похоже на производное от фрейма
    Name: String;
    NumVertex: Integer;
    Vertexes: array of TVector3;
  end;

type
  T3DModel = record // собственно модель соответствующм образом подготовленая
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
///////////////////////////////////////////////
var Next: integer;
/////////////////////////////////////////////////

procedure LoadModel(Filename: String; var Model: T3DModel);
procedure FreeModel(var Model: T3DModel);
procedure AnimateModel(var Model: T3DModel);

implementation

procedure LoadModel(Filename: String; var Model: T3DModel);
var F: File;
    i, j: Integer;

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
 Seek(F, Header.OffsetFrames);
 SetLength(Frames, Header.NumFrames);
 for i := 0 to Header.NumFrames - 1 do
  begin
   SetLength(Frame.Vertices, Header.NumVertices);
   BlockRead(F, Frame.Scale, SizeOf(Frame.Scale));
   BlockRead(F, Frame.Translate, SizeOf(Frame.Translate));
   BlockRead(F, Frame.Name, SizeOf(Frame.Name));
   BlockRead(F, Frame.Vertices[0], SizeOf(TMD2AliasTriangle) * Header.NumVertices);

   SetLength(Frames[i].Vertices, Header.NumVertices);
   StrCopy(Frames[i].Name, Frame.Name);
   for j := 0 to Header.NumVertices - 1 do
    begin
     Frames[i].Vertices[j].Vertex[0] := Frame.Vertices[j].Vertex[0] * Frame.Scale[0] + Frame.Translate[0];
     Frames[i].Vertices[j].Vertex[2] := -1 * (Frame.Vertices[j].Vertex[1] * Frame.Scale[1] + Frame.Translate[1]);
     Frames[i].Vertices[j].Vertex[1] := Frame.Vertices[j].Vertex[2] * Frame.Scale[2] + Frame.Translate[2];
    end;
  end;

 Close(F);//непонял..а gl команды почему не читал???

// Convert Data Structures
 Model.NumTexCoords := Header.NumTexCoords;
 Model.NumFaces := Header.NumTriangles;
 SetLength(Model.TexCoords, Model.NumTexCoords);
 SetLength(Model.Faces, Model.NumFaces);

 for i := 0 to Model.NumTexCoords - 1 do   //чето не понятное
  begin
   Model.TexCoords[i].X := TexCoords[i].U / Header.SkinWidth;
   Model.TexCoords[i].Y := 1 - TexCoords[i].V / Header.SkinHeight;
  end;

 for i := 0 to Model.NumFaces - 1 do
  begin
   Model.Faces[i].VertexIndex[0] := Triangles[i].VertexIndices[0];
   Model.Faces[i].VertexIndex[1] := Triangles[i].VertexIndices[1];
   Model.Faces[i].VertexIndex[2] := Triangles[i].VertexIndices[2];

   Model.Faces[i].TexCoordIndex[0] := Triangles[i].TextureIndices[0];
   Model.Faces[i].TexCoordIndex[1] := Triangles[i].TextureIndices[1];
   Model.Faces[i].TexCoordIndex[2] := Triangles[i].TextureIndices[2];
  end;

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

// Parse animations
 for i := 0 to Model.NumObjects - 1 do
  begin
   Name := Model.Objects[i].Name;

//   if TryStrToInt(Copy(Name, Length(Name) - 1, 2), FrameNum) then
    begin
     Delete(Name, Length(Name) - 1, 2);
    end;
//   else
 //   if TryStrToInt(Copy(Name, Length(Name), 1), FrameNum) then
     begin
      Delete(Name, Length(Name), 1);
     end;
//    else
     begin
      FrameNum := 1;
     end;

   if (Name <> LastName) then
    begin
     if LastName <> '' then
      begin
       Animation.Name := LastName;
       Animation.EndFrame := i;
       Inc(Model.NumAnimations);
       SetLength(Model.Animations, Model.NumAnimations);
       Model.Animations[Model.NumAnimations - 1] := Animation;
       ZeroMemory(@Animation, SizeOf(Animation));
      end;
     Animation.StartFrame := FrameNum - 1 + i;
    end;

   LastName := Name;
  end;

// Free memory
 TexCoords := nil;
 Triangles := nil;
 Frames := nil;

 //model.Cf:=1;  Animation.StartFrame    @Model.Animations[1]       @
 model.Cf:=Model.Animations[1].StartFrame;
end;

procedure FreeModel(var Model: T3DModel);
begin
 Model.Objects := nil;
 Model.Animations := nil;
end;

function ReturnCurrentTime(var Model: T3DModel; NextFrame: Integer): Single;
var Time, t: Single;
    b: tbitmap; // почему прога не считает его битмапом?
begin
 if Model.Objects = nil then Exit;


                                           {
 Time := GetTickCount;   //читает системное время виндовс
 Model.ElapsedTime := Time - Model.LastTime;     //зачемто запоминает его
 t := Model.ElapsedTime/(1000.0/ANIMATION_SPEED);//~200

 if Model.ElapsedTime >= (1000.0/ANIMATION_SPEED) then   }
  begin
   Model.Cf := NextFrame;  //urrentFrame
   Model.LastTime := Time;
  end;
// b.free;
 Result := t;
end;

procedure AnimateModel(var Model: T3DModel);
var i,  WhichVertex,  //  Next,
    Index1, Index2: Integer;

    Time: Single;
    Point1, Point2: TVector3;

    Animation: ^TAnimation;
    Frame, NextFrame: ^T3DObject;
begin
 if Model.Objects = nil then Exit;

 Animation :=@Model.Animations[1];//@Model.Animations[Model.CurrentAnim]; // [];// Model.cf 0
 //Next := Model.Cf + 1;  // один кадр буду смореть хоть и с глюками urrentFrame
 //if Next >= Animation.EndFrame then Next := Animation.StartFrame;

 Frame := @Model.Objects[Model.Cf];
 NextFrame := @Model.Objects[Next];

 Time := ReturnCurrentTime(Model, Next);

 glBegin(GL_TRIANGLES);
 for i := 0 to Model.NumFaces - 1 do  //   рисую плоскости
  //if i in [1..30] then
  for WhichVertex := 0 to 2 do
   begin
    Index1 := Model.Faces[i].TexCoordIndex[WhichVertex];
    Index2 := Model.Faces[i].VertexIndex[WhichVertex];

    Point1 := Frame.Vertexes[Index2];
    Point2 := NextFrame.Vertexes[Index2];

    glTexCoord2f(Model.TexCoords[Index1].X, Model.TexCoords[Index1].Y);
    glVertex3f(Point1.X + Time * (Point2.X - Point1.X),
     Point1.Y + Time * (Point2.Y - Point1.Y), Point1.Z + Time * (Point2.Z - Point1.Z));
   end;
 glEnd;
end;

end.
