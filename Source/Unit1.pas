unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, ToolWin, Buttons, Menus, ActnList,
  Sockets, WinSock, Inifiles, XPMan;

type
  TForm1 = class(TForm)
    TcpClient1: TTcpClient;
    StatusBar1: TStatusBar;
    XPManifest1: TXPManifest;
    Memo1: TMemo;
    Memo2: TMemo;
    BitBtn1: TBitBtn;
    Editchar: TEdit;
    Editme: TEdit;
    MainMenu1: TMainMenu;
    PopupMenu1: TPopupMenu;
    F1: TMenuItem;
    Label1: TLabel;
    Label3: TLabel;
    BitBtn2: TBitBtn;
    ListBox1: TListBox;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Label4: TLabel;
    N4: TMenuItem;
    N5: TMenuItem;
    S1: TMenuItem;
    N6: TMenuItem;
    TcpServer1: TTcpServer;
    BitBtn7: TBitBtn;
    OpenDialog1: TOpenDialog;
    BitBtn8: TBitBtn;
    Image1: TImage;
    N7: TMenuItem;
    ListBox2: TListBox;
    Edit1: TEdit;
    Label2: TLabel;
    Label5: TLabel;
    ListBox3: TListBox;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N13: TMenuItem;
    procedure Memo2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure N13Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BitBtn9Click(Sender: TObject);
    procedure ListBox3DblClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure TcpServer1Accept(Sender: TObject;
      ClientSocket: TCustomIpClient);
    procedure FormShow(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure EditcharKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image1DblClick(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
      function dow(str:string):string;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TClientDataThread = class(TThread)
  private
  public
    ListBuffer :TStringList;
    TargetList :TStrings;
    procedure synchAddDataToControl;
    constructor Create(CreateSuspended: Boolean);
    procedure Execute; override;
    procedure Terminate;
  end;

  //用户记录
  TUser = packed record
     UserComputerName : String[30];
     UserNickName : String[20];
     UserIPAddress : String[15];
  end;

    //查找网络内的计算机;
    Function FindAllComputer(var ComputerList : TStringList ): Boolean;
    //由主机名得到IP地址
    function GetIP(Name: string) : string;
    //查看计算机是否在线
    function FindComputer(ComputerName: string):Boolean;
    //获得所有工作组
    function GetWorkGroupList(var myList : TStringList ) : Boolean;
    //获得工作组内的全部计算机
    function GetComputerList(myWorkGroup:string ;var myList:TStringList):Boolean;

var
  Form1: TForm1;

implementation
uses unit2,unit3;
{$R *.dfm}
function TForm1.dow(str: string):string;
var
  i:integer;
begin
  for I := 1 to length(str) do
  begin
    if str[i]=#13 then
    str[i]:=' ';
  end;
  dow:=str;
end;
constructor TClientDataThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := true;
  ListBuffer := TStringList.Create;
end;

procedure TClientDataThread.Terminate;
begin
  ListBuffer.Free;
  inherited;
end;

procedure TClientDataThread.Execute;
begin
  Synchronize(synchAddDataToControl);
end;

procedure TClientDataThread.synchAddDataToControl;
begin
 TargetList.AddStrings(ListBuffer);
end;
procedure TForm1.BitBtn1Click(Sender: TObject);
var   I: Integer;
       str: String;
begin
if trim(dow(Memo2.Lines.gettext)) <> '' then
 begin
  if FindComputer(trim(EditChar.Text)) then
  begin
    TcpClient1.RemoteHost :=EditChar.Text;//'Localhost';
    TcpClient1.RemotePort :=edit1.Text;
    try
    if TcpClient1.Connect
    then begin
             str := '';
         str :=#13#10+'对 '+ TcpClient1.RemoteHost+
               ' 说：'+#13#10+'  '+dow(Memo2.Lines.gettext);
         Memo1.Lines.Append(dow(Memo2.Lines.gettext));
         TcpClient1.Sendln(dow(Memo2.Lines.gettext));
         end;
    finally
      TcpClient1.Disconnect;
      Memo2.Clear;
      memo2.SetFocus;
    end;
  end
  else
      begin
       Application.MessageBox(Pchar('朋友不在线，不能发送消息！'),
              Pchar('错误！'),MB_OK+MB_ICONERROR);
      end;
 end
 else
    begin
     Application.MessageBox(Pchar('不要发送空消息'),
               Pchar('错误！'),MB_OK+MB_ICONERROR);
    end;
end;


procedure TForm1.TcpServer1Accept(Sender: TObject;
  ClientSocket: TCustomIpClient);
var
  s: string;
  DataThread: TClientDataThread;
begin
  DataThread:= TClientDataThread.Create(True);
  DataThread.TargetList := Memo1.lines;
  DataThread.ListBuffer.Add(#13#10+
         ' 来自 ' + ClientSocket.RemoteHost +' 说：');
  s := ClientSocket.Receiveln;
  while s <> '' do
  begin
    DataThread.ListBuffer.Add(s);
    s := ClientSocket.Receiveln;
  end;
  DataThread.Resume;
end;
function GetIP(Name: string) : string;
type
  JlrPInAddr = array [0..10] of PInAddr;
  P_JlrPInAddr = ^JlrPInAddr;
var
  phe :PHostEnt;
  I : Integer;
  pptr : P_JlrPInAddr;
  GInitData : TWSADATA;
begin
    WSAStartup($101, GInitData);  //Socket连接
    Result := '';
    phe := GetHostByName(Pchar(Name));
    if phe = nil then Exit;
    pptr := P_JlrPInAddr(phe^.h_addr_list); //转换为IP地址
    I := 0;
    while pptr^[I] <> nil do begin
      Result:=StrPas(inet_ntoa(pptr^[I]^));  //返回IP地址
      Inc(I);
    end;
    WSACleanup;    //Socket关闭
end;

type
  TNetResourceArray = ^TNetResource;

function GetWorkGroupList( var myList : TStringList ) : Boolean;
var
  NetResource : TNetResource;
  Buf : Pointer;
  Count,BufSize,Res : DWORD;
  lphEnum : THandle;
  p: TNetResourceArray;
  i,j : SmallInt;
  NetworkTypeList : TList;
begin
  Result := False;
  NetworkTypeList := TList.Create;
  myList.Clear;
  Res := WNetOpenEnum( RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, nil,lphEnum);
  if Res <> NO_ERROR then exit;
  Count := $FFFFFFFF;
  BufSize := 8192;
  GetMem(Buf, BufSize);
  Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
  if ( Res = ERROR_NO_MORE_ITEMS ) or (Res <> NO_ERROR ) then Exit;

  P := TNetResourceArray(Buf);
  for I := 0 to Count - 1 do  //记录各个网络类型的信息
  begin
    NetworkTypeList.Add(p);
    Inc(P);
  end;
  Res:= WNetCloseEnum(lphEnum);
  if Res <> NO_ERROR then exit;
  for J := 0 to NetworkTypeList.Count-1 do
  begin
    NetResource := TNetResource(NetworkTypeList.Items[J]^);
    Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK,
                        RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
    if Res <> NO_ERROR then break;
    while true do
    begin
      Count := $FFFFFFFF;
      BufSize := 8192;
      GetMem(Buf, BufSize);
      Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
      if ( Res = ERROR_NO_MORE_ITEMS ) or (Res <> NO_ERROR) then break;
      P := TNetResourceArray(Buf);
      for I := 0 to Count - 1 do
      begin
        myList.Add(StrPAS( P^.lpRemoteName ));
        Inc(P);
      end;
    end;
    Res := WNetCloseEnum(lphEnum);
    if Res <> NO_ERROR then break;
  end;
  Result := True;
  FreeMem(Buf);
  NetworkTypeList.Destroy;
end;

function GetComputerList(myWorkGroup:string ;var myList:TStringList):Boolean;
var
  NetResource: TNetResource;
  Buf : Pointer;
  Count,BufSize,Res : DWord;
  Ind : Integer;
  lphEnum : THandle;
  Temp: TNetResourceArray;
begin
  Result := False;
  myList.Clear;
  FillChar(NetResource, SizeOf(NetResource), 0);
  NetResource.lpRemoteName := @myWorkGroup[1];
  NetResource.dwDisplayType := RESOURCEDISPLAYTYPE_SERVER;
  NetResource.dwUsage := RESOURCEUSAGE_CONTAINER;
  NetResource.dwScope := RESOURCETYPE_DISK;
  Res := WNetOpenEnum( RESOURCE_GLOBALNET, RESOURCETYPE_DISK,RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
  if Res <> NO_ERROR then Exit;
  While true Do
  begin
    Count := $FFFFFFFF;
    BufSize := 8192;
    GetMem(Buf, BufSize);
    Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
    if Res = ERROR_NO_MORE_ITEMS then break;
    if (Res <> NO_ERROR) then Exit;
    Temp := TNetResourceArray(Buf);
    for Ind := 0 to Count - 1 do
    begin
       myList.Add(Temp^.lpRemoteName);
       Inc(Temp);
    end;
  end;
  Res := WNetCloseEnum(lphEnum);
  if Res <> NO_ERROR then exit;
  Result := True;
  FreeMem(Buf);
end;
Function FindAllComputer(var ComputerList : TStringList ): Boolean;
var WorkGroupList, TempList: TStringList;
    i, j : Integer;
begin
  WorkGroupList := TStringList.Create;
  TempList := TStringList.Create;
  //查找所有在线用户,将其添加到用户列表中
  Result := False;
  try
  GetWorkGroupList(WorkGroupList);
  for i := 0 to WorkGroupList.Count - 1 do
      begin
        GetComputerList(WorkGroupList.Strings[i],TempList);
        for j := 0 to TempList.Count - 1 do
          begin
          while Pos('\',TempList.Strings[j])<>0 do
              TempList.Strings[j] := copy(TempList.Strings[j],0,
              Pos('\',TempList.Strings[j])-1)
              +copy(TempList.Strings[j],Pos('\',TempList.Strings[j])+1,
              length(TempList.Strings[j]));
            ComputerList.Add(TempList.Strings[j]);
          end;
        TempList.Clear;
      end;
  finally
  TempList.Free;
  WorkGroupList.Free;
  Result := True;
  end;
end;
function FindComputer(ComputerName: string):Boolean;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
begin
  Result := False;
  WSAStartup(2, WSAData);
  HostEnt := Gethostbyname(PChar(ComputerName));
  if HostEnt = nil
  then Result :=False
  else Result:=True;
  WSACleanup;
end;


procedure TForm1.FormShow(Sender: TObject);
var
  computerlist:tstringlist;
  name:string;
  i:integer;
begin
  ComputerList := TStringList.Create;
if FindAllComputer(ComputerList) then
    for i := 0 to ComputerList.Count - 1 do
         ListBox3.Items.Add(ComputerList.Strings[i]);
ListBox3.ItemIndex:=0;
ComputerList.Free;
  if listbox1.Count<>0
  then begin
  listbox1.ItemIndex:=0;
  listbox1.OnDblClick(sender);
  end;
  tcpserver1.Active:=true;
   editme.Text:=TcpClient1.LocalHostName;
   memo2.SetFocus;
   tcpclient1.Connect;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  close;
end;






procedure TForm1.BitBtn3Click(Sender: TObject);
var
 n:integer;
begin
  n:=listbox1.ItemIndex;
  form2.Caption:='增加';
  form2.ShowModal;
   if listbox1.Count<>0
   then listbox1.ItemIndex:=n;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
var
  n:integer;
begin
   n:=listbox1.ItemIndex;
   if not listbox1.ItemIndex<0
   then
   begin
   form2.Caption:='修改';
   form2.ShowModal;
   end;
   if listbox1.Count<>0
   then listbox1.ItemIndex:=n;
end;



procedure TForm1.ListBox1DblClick(Sender: TObject);
var
  pl1,pl2:tstrings;
  str:string;
  n:integer;
begin
  pl1:=listbox1.Items;
  pl2:=listbox2.Items;
  n:=listbox1.ItemIndex;
  str:=pl1[n];
  editchar.Text:=str;
  statusbar1.Panels[0].Text:='对方IP: '+pl2[n];
  str:='';
  str:=pl1[n];
  statusbar1.Panels[1].Text:='状态: 待命!!';
  statusbar1.Panels[2].Text:='对方名字: '+str;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  listbox1.Items.SaveToFile('./friends/friendsname.ye');
  listbox2.Items.SaveToFile('./friends/friendsip.ye');

  if MessageDlg('确定要退出吗?', mtInformation ,[mbyes,mbno],0) = mryes
  then
    begin
      tcpclient1.Disconnect;
      tcpserver1.Destroy;
      action:=cafree;
    end
    else
    action := caNone;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var
  n:integer;
begin
if MessageDlg('确定要删除吗?', mtInformation ,[mbyes,mbno],0) = mryes
then begin
  n:=listbox1.ItemIndex;
  if not n<0
  then
  listbox1.Items.Delete(n);
  if listbox1.Count<>0
  then
  listbox1.ItemIndex:=n;
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  tcpserver1.LocalPort:='5858';
  tcpserver1.Active:=true;
  listbox1.Items.LoadFromFile('./friends/friendsname.ye');
  listbox2.Items.LoadFromFile('./friends/friendsip.ye');
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  n:integer;
begin
  n:=listbox1.ItemIndex;
  try
  listbox1.Items.SaveToFile('./friends/friendsname.ye');
  listbox2.Items.SaveToFile('./friends/friendsip.ye');
  showmessage('保存成功!');
  except
  showmessage('保存失败!');
  end;
  listbox1.ItemIndex:=n;
end;



procedure TForm1.BitBtn7Click(Sender: TObject);
var
  n:integer;
begin
  n:=listbox1.ItemIndex;
  try
  listbox1.Items.LoadFromFile('./friends/friendsname.ye');
  listbox2.Items.LoadFromFile('./friends/friendsip.ye');
  except
  showmessage('载入失败!');
  end;
  listbox1.ItemIndex:=n;
end;


procedure TForm1.N6Click(Sender: TObject);
begin
   memo1.Clear;
end;

procedure TForm1.EditcharKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13
  then memo2.SetFocus;
end;


procedure TForm1.Image1DblClick(Sender: TObject);
begin
  form3.ShowModal;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key=46
   then bitbtn5.Click;
end;


procedure TForm1.ListBox3DblClick(Sender: TObject);
var
  n:integer;
begin
  n:=listbox3.ItemIndex;
  editchar.Text:=listbox3.Items[n];
end;

procedure TForm1.BitBtn9Click(Sender: TObject);
begin
  tcpserver1.LocalPort:=edit1.Text;
  tcpserver1.Active:=true;
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key=13
   then bitbtn9.Click;
end;

procedure TForm1.BitBtn10Click(Sender: TObject);
var
  i:integer;
  computerlist:tstringlist;
begin
ComputerList := TStringList.Create;
if FindAllComputer(ComputerList) then
    for i := 0 to ComputerList.Count - 1 do
         ListBox3.Items.Add(ComputerList.Strings[i]);
ListBox3.ItemIndex:=0;
ComputerList.Free;
end;

procedure TForm1.BitBtn11Click(Sender: TObject);
begin
  editchar.Text:=editme.Text;
end;

procedure TForm1.N8Click(Sender: TObject);
begin
   memo1.Clear;
end;

procedure TForm1.N11Click(Sender: TObject);
begin
memo1.SelectAll;
end;

procedure TForm1.N13Click(Sender: TObject);
begin
  memo1.CopyToClipboard;
end;




procedure TForm1.Memo2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ( key=13 ) and (ssctrl in shift)
   then bitbtn1.Click;
end;


end.
