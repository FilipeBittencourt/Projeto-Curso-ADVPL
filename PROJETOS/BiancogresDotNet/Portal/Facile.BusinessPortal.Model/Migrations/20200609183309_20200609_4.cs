using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20200609_4 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotaFiscal");

            migrationBuilder.CreateTable(
                name: "NotaFiscalCompra",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    FornecedorID = table.Column<long>(nullable: false),
                    TransportadoraID = table.Column<long>(nullable: true),
                    PedidoCompraID = table.Column<long>(nullable: false),
                    Numero = table.Column<string>(nullable: true),
                    Serie = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    NomeProduto = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    UnidadeProduto = table.Column<string>(nullable: true),
                    Quantidade = table.Column<decimal>(nullable: false),
                    Valor = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    DataRecebimento = table.Column<DateTime>(nullable: false),
                    DataAgendamento = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotaFiscalCompra", x => x.ID);
                    table.ForeignKey(
                        name: "FK_NotaFiscalCompra_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscalCompra_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscalCompra_PedidoCompra_PedidoCompraID",
                        column: x => x.PedidoCompraID,
                        principalTable: "PedidoCompra",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscalCompra_Transportadora_TransportadoraID",
                        column: x => x.TransportadoraID,
                        principalTable: "Transportadora",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscalCompra_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_EmpresaID",
                table: "NotaFiscalCompra",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_FornecedorID",
                table: "NotaFiscalCompra",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_PedidoCompraID",
                table: "NotaFiscalCompra",
                column: "PedidoCompraID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_TransportadoraID",
                table: "NotaFiscalCompra",
                column: "TransportadoraID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_UnidadeID",
                table: "NotaFiscalCompra",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotaFiscalCompra");

            migrationBuilder.CreateTable(
                name: "NotaFiscal",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    CodigoProduto = table.Column<string>(nullable: true),
                    DataAgendamento = table.Column<DateTime>(nullable: false),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    DataRecebimento = table.Column<DateTime>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false),
                    Habilitado = table.Column<bool>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    NomeProduto = table.Column<string>(nullable: true),
                    Numero = table.Column<string>(nullable: true),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    PedidoCompraID = table.Column<long>(nullable: false),
                    Quantidade = table.Column<decimal>(nullable: false),
                    Serie = table.Column<string>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    TransportadoraID = table.Column<long>(nullable: true),
                    UnidadeID = table.Column<long>(nullable: true),
                    UnidadeProduto = table.Column<string>(nullable: true),
                    Valor = table.Column<decimal>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotaFiscal", x => x.ID);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_PedidoCompra_PedidoCompraID",
                        column: x => x.PedidoCompraID,
                        principalTable: "PedidoCompra",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Transportadora_TransportadoraID",
                        column: x => x.TransportadoraID,
                        principalTable: "Transportadora",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NotaFiscal_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_EmpresaID",
                table: "NotaFiscal",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_FornecedorID",
                table: "NotaFiscal",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_PedidoCompraID",
                table: "NotaFiscal",
                column: "PedidoCompraID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_TransportadoraID",
                table: "NotaFiscal",
                column: "TransportadoraID");

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscal_UnidadeID",
                table: "NotaFiscal",
                column: "UnidadeID");
        }
    }
}
