unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation
 uses unit1;
{$R *.dfm}

procedure TForm2.BitBtn1Click(Sender: TObject);
var
n:integer;
str:string;
begin
  if trim(edit1.Text)=''
  then begin
              Application.MessageBox(Pchar('名字不可为空!'),
              Pchar('错误！'),MB_OK+MB_ICONERROR);
              edit1.SetFocus;
      end
  else begin
         if form2.Caption='增加'
         then
         begin
         str:=edit1.Text;
         form1.ListBox1.Items.Add(str);
         if trim(edit2.Text)<>''
         then begin
                form1.ListBox2.Items.Append(edit2.Text);
              end;
           form2.Close;
         end
         else
         begin
                str:='';
                n:=form1.ListBox1.ItemIndex;
                str:=edit1.Text;
                form1.ListBox1.Items[n]:=str;
                str:='';
                if trim(edit2.Text)<>''
                then begin
                       form1.ListBox2.Items[n]:=edit2.Text; 
                     end;
                  form2.Close;
              end;
       end;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
begin
  form2.Close;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  n:integer;
begin
  if form2.Caption='增加'
  then begin
         edit1.Text:='';
       end
  else begin
         n:=0;
         n:=form1.ListBox1.ItemIndex;
         edit1.Text:=form1.ListBox1.Items[n];
       end;
end;

procedure TForm2.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13
  then edit2.SetFocus;
end;

procedure TForm2.Edit2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key=13
  then bitbtn1.Click;
end;

end.
