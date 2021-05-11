using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20200608_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PedidoCompra",
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
                    DataEntrega = table.Column<DateTime>(nullable: false),
                    Pedido = table.Column<string>(nullable: true),
                    NomeProduto = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    UnidadeProduto = table.Column<string>(nullable: true),
                    Quantidade = table.Column<decimal>(nullable: false),
                    Saldo = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    Deletado = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PedidoCompra", x => x.ID);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PedidoCompra");
        }
    }
}
