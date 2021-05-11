using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201119_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoItemCotacao",
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
                    SolicitacaoServicoItemID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false),
                    Observacao = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    Preco = table.Column<decimal>(nullable: false),
                    IPI = table.Column<decimal>(nullable: false),
                    ValorSubstituicao = table.Column<decimal>(nullable: false),
                    PrazoEntrega = table.Column<int>(nullable: false),
                    Moeda = table.Column<string>(nullable: true),
                    Marca = table.Column<string>(nullable: true),
                    AtendeTotalmente = table.Column<int>(nullable: false),
                    AtendeItem = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoItemCotacao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_SolicitacaoServicoItem_SolicitacaoServicoItemID",
                        column: x => x.SolicitacaoServicoItemID,
                        principalTable: "SolicitacaoServicoItem",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemCotacao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_EmpresaID",
                table: "SolicitacaoServicoItemCotacao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_FornecedorID",
                table: "SolicitacaoServicoItemCotacao",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_SolicitacaoServicoItemID",
                table: "SolicitacaoServicoItemCotacao",
                column: "SolicitacaoServicoItemID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemCotacao_UnidadeID",
                table: "SolicitacaoServicoItemCotacao",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SolicitacaoServicoItemCotacao");
        }
    }
}
