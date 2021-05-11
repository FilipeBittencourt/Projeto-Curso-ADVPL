using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20200609_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "NotaFiscalCompra",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    ChaveUnica = table.Column<string>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    FornecedorCPFCNPJ = table.Column<string>(nullable: true),
                    FornecedorLoja = table.Column<string>(nullable: true),
                    FornecedorCodigoERP = table.Column<string>(nullable: true),
                    TransportadoraCPFCNPJ = table.Column<string>(nullable: true),
                    Numero = table.Column<string>(nullable: true),
                    Serie = table.Column<string>(nullable: true),
                    NumeroPedido = table.Column<string>(nullable: true),
                    NumeroPedidoItem = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    ProdutoNome = table.Column<string>(nullable: true),
                    ProdutoCodigo = table.Column<string>(nullable: true),
                    ProdutoUnidade = table.Column<string>(nullable: true),
                    Quantidade = table.Column<decimal>(nullable: false),
                    Valor = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotaFiscalCompra", x => x.ID);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotaFiscalCompra");
        }
    }
}
