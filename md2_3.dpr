program md2_3;

uses
  Forms,
  Unit3md2 in 'Unit3md2.pas' {Form1},
  female in 'female.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
