unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.JSON, MVCFramework.RESTClient, UEfetuarPedidoDTOImpl, System.Rtti,
  UPizzaSaborEnum, UPizzaTamanhoEnum, UConsultarPedidoDTOImpl;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  if edtDocumentoCliente.Text = '' then
  begin
    ShowMessage('Campo "Documento" deve ser preenchido!');
    edtDocumentoCliente.SetFocus;
    Exit;
  end;

  if cmbTamanhoPizza.Text = '' then
  begin
    ShowMessage('Campo "Tamanho da Pizza" deve ser preenchido!');
    cmbTamanhoPizza.SetFocus;
    Exit;
  end;

  if cmbSaborPizza.Text = '' then
  begin
    ShowMessage('Campo "Sabor da Pizza" deve ser preenchido!');
    cmbSaborPizza.SetFocus;
    Exit;
  end;



  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oEfetuarPedido := TEfetuarPedidoDTO.Create;
    try
      oEfetuarPedido.PizzaTamanho :=
        TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text);
      oEfetuarPedido.PizzaSabor :=
        TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
      oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
        TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
    finally
      oEfetuarPedido.Free;
    end;
  finally
    Clt.Free;
  end;


  cmbSaborPizza.ItemIndex   := -1;
  cmbTamanhoPizza.ItemIndex := -1;
  edtDocumentoCliente.Text  := '';
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Clt: TRestClient;
  oConsultarPedido: TConsultarPedidoDTO;
begin
  if edtDocumentoCliente.Text = '' then
  begin
    ShowMessage('Campo "Documento" deve ser preenchido!');
    edtDocumentoCliente.SetFocus;
    Exit;
  end;


  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oConsultarPedido := TConsultarPedidoDTO.Create;
    try
      oConsultarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/ConsultarPedido', [],
        TJson.ObjecttoJsonString(oConsultarPedido)).BodyAsString;
    finally
      oConsultarPedido.Free;
    end;
  finally
    Clt.Free;
  end;


  cmbSaborPizza.ItemIndex   := -1;
  cmbTamanhoPizza.ItemIndex := -1;
  edtDocumentoCliente.Text  := '';
end;

end.
