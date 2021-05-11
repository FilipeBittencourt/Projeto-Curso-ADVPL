using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201210_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoItemMedicao",
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
                    Data = table.Column<DateTime>(nullable: false),
                    UnidadeMedicao = table.Column<string>(nullable: true),
                    Quantidade = table.Column<decimal>(nullable: false),
                    ValorMedicaoRestante = table.Column<decimal>(nullable: false),
                    ValorMedicao = table.Column<decimal>(nullable: false),
                    Valor = table.Column<decimal>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoItemMedicao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemMedicao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemMedicao_SolicitacaoServicoItem_SolicitacaoServicoItemID",
                        column: x => x.SolicitacaoServicoItemID,
                        principalTable: "SolicitacaoServicoItem",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoItemMedicao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemMedicao_EmpresaID",
                table: "SolicitacaoServicoItemMedicao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemMedicao_SolicitacaoServicoItemID",
                table: "SolicitacaoServicoItemMedicao",
                column: "SolicitacaoServicoItemID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemMedicao_UnidadeID",
                table: "SolicitacaoServicoItemMedicao",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SolicitacaoServicoItemMedicao");
        }
    }
}
