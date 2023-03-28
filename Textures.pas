unit Textures;

///////////////////////////////////////
//   Unit : Textures
//   Date : 03/02/2002
// Author : Vashchaev 'viv' Ivan
// e-Mail : ivanv@softhome.net
///////////////////////////////////////

interface

uses Windows, SysUtils, OpenGL;

procedure LoadTexture(Filename: String; var ID: GLuint);
procedure DestroyTexture(var ID: GLuint);
procedure EnableTexture(var ID: GLuint);

procedure glGenTextures(N: GLsizei; Textures: PGLuint); stdcall; external opengl32;
procedure glBindTexture(Target: GLEnum; Texture: GLuint); stdcall; external opengl32;
procedure glDeleteTextures(N: GLsizei; Textures: PGLuint); stdcall; external opengl32;
function gluBuild2DMipmaps(Target: GLenum; Components, Width, Height: GLint; Format, atype: GLenum; Data: Pointer): GLint; stdcall; external glu32;

implementation

procedure LoadTexture(Filename: String; var ID: GLuint);
type
  TTGAHeader = packed record
   FileType, ColorMapType, ImageType: Byte;
   ColorMapSpec: array[0..4] of Byte;
   OrigX, OrigY, Width, Height: array [0..1] of Byte;
   BPP: Byte;
   ImageInfo: Byte;
  end;
var F: File;
    Header: TTGAHeader;
    Image: array of Byte;
    Temp: Byte;
    BytesRead, Width, Height, ColorDepth, ImageSize, i: Integer;
begin
 if not FileExists(Filename) then Exit;
 if Copy(Lowercase(Filename), Length(Filename)-3, 4) <> '.tga' then Exit;

 AssignFile(F, Filename);
 Reset(F, 1);
 BlockRead(F, Header, SizeOf(Header));

 Width := Header.Width[0] + Header.Width[1] * 256;
 Height := Header.Height[0] + Header.Height[1] * 256;
 ColorDepth := Header.BPP;
 ImageSize := Width * Height * (ColorDepth div 8);

 SetLength(Image, ImageSize);
 BlockRead(F, Image[0], ImageSize, BytesRead);

 if (Header.ImageType <> 2) or (Header.ColorMapType <> 0) or (BytesRead <> ImageSize) then
   begin
    CloseFile(F);
    Image := nil;
    MessageBox(0, PChar('Couldn''t load "'+ Filename +'"'), PChar('TGA File Error'), MB_OK);
    Exit;
   end;

 for i := 0 to Width * Height - 1 do
  begin
   if ColorDepth = 24 then
    begin
     Temp := Image[i * 3];
     Image[i * 3] := Image[i * 3 + 2];
     Image[i * 3 + 2] := Temp;
    end;

   if ColorDepth = 32 then
    begin
     Temp := Image[i * 4];
     Image[i * 4] := Image[i * 4 + 2];
     Image[i * 4 + 2] := Temp;
//     if (Image[i * 4] > $32) and (Image[i * 4 + 1] > $32) and (Image[i * 4 + 2] > $32) then Image[i * 4 + 3] := $FF;
    end;
  end;

 glGenTextures(1, @ID);
 glBindTexture(GL_TEXTURE_2D, ID);

 glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

 if ColorDepth = 24 then gluBuild2DMipmaps(GL_TEXTURE_2D, 3, Width, Height, GL_RGB, GL_UNSIGNED_BYTE, Addr(Image[0]));
 if ColorDepth = 32 then gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, Addr(Image[0]));

 Image := nil;
end;

procedure DestroyTexture(var ID: GLuint);
begin
 glDeleteTextures(1, @ID);
end;

procedure EnableTexture(var ID: GLuint);
begin
 glBindTexture(GL_TEXTURE_2D, ID);
end;

end.

