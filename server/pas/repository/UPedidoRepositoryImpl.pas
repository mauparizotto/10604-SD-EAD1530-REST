unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
      const ATempoPreparo: Integer; const ACodigoCliente: Integer);

    procedure ConsultaPedidoP(out APizzaTamanho: TPizzaTamanhoEnum; out APizzaSabor: TPizzaSaborEnum; out AValorPedido: Currency;
      out ATempoPreparo: Integer; const ACodigoCliente: Integer);

    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO
    : String =
    'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, vl_pedido, nr_tempopedido) VALUES (:pCodigoCliente, :pDataPedido, :pDataEntrega, :pValorPedido, :pTempoPedido)';

  CMD_SELECT_PEDIDO
    : String =
    ' Select'+
    '   PD.nr_tempopedido,'+
		'   PD.vl_pedido'+
    ' From tb_pedido PD'+
    '   Left Join tb_cliente Cl on (CL.id = PD.cd_cliente) '+
    ' Where CL.nr_documento = :pDocumento '+
    ' Order By PD.dt_entrega Desc'+
    ' LIMIT 1' ;

  { TPedidoRepository }

constructor TPedidoRepository.Create;
begin
  inherited;

  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer);
begin
  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger := ATempoPreparo;

  FFDQuery.Prepare;
  FFDQuery.ExecSQL(True);
end;

procedure TPedidoRepository.ConsultaPedidoP(out APizzaTamanho: TPizzaTamanhoEnum; out APizzaSabor: TPizzaSaborEnum; out AValorPedido: Currency;
      out ATempoPreparo: Integer; const ACodigoCliente: Integer);
begin
  FFDQuery.SQL.Text := CMD_SELECT_PEDIDO;

  FFDQuery.ParamByName('pDocumento').AsInteger := ACodigoCliente;

  FFDQuery.Open;
  if (not FFDQuery.IsEmpty) then
  begin
    ATempoPreparo := FFDQuery.FieldByName('nr_tempopedido').AsInteger;
    AValorPedido  := FFDQuery.FieldByName('vl_pedido').AsInteger;
    APizzaTamanho := enPequena; // pegar banco
    APizzaSabor   := enCalabresa; // pegar banco
  end else
    raise Exception.Create('Pedito não encontrado');
end;

end.
