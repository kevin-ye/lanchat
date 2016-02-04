unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TForm3 = class(TForm)
    Edit1: TEdit;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    procedure Memo1Enter(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Memo1Enter(Sender: TObject);
begin
   edit1.SetFocus;
end;

procedure TForm3.BitBtn1Click(Sender: TObject);
begin
   form3.Close;
end;

end.
