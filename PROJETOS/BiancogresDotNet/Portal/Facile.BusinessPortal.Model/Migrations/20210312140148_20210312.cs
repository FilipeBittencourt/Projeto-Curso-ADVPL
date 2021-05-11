using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210312 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "SolicitacaoServicoMedicaoID",
                table: "SolicitacaoServicoItemMedicao",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoMedicao",
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
                    SolicitacaoServicoID = table.Column<long>(nullable: false),
                    Data = table.Column<DateTime>(nullable: false),
                    Status = table.Column<int>(nullable: false),
                    UsuarioID = table.Column<long>(nullable: true),
                    ObservacaoNotaFiscal = table.Column<string>(nullable: true),
                    NomeAnexoNotaFiscal = table.Column<string>(nullable: true),
                    TipoAnexoNotaFiscal = table.Column<string>(nullable: true),
                    ArquivoAnexoNotaFiscal = table.Column<byte[]>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoMedicao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicao_SolicitacaoServico_SolicitacaoServicoID",
                        column: x => x.SolicitacaoServicoID,
                        principalTable: "SolicitacaoServico",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicao_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoItemMedicao_SolicitacaoServicoMedicaoID",
                table: "SolicitacaoServicoItemMedicao",
                column: "SolicitacaoServicoMedicaoID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicao_EmpresaID",
                table: "SolicitacaoServicoMedicao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicao_SolicitacaoServicoID",
                table: "SolicitacaoServicoMedicao",
                column: "SolicitacaoServicoID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicao_UnidadeID",
                table: "SolicitacaoServicoMedicao",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicao_UsuarioID",
                table: "SolicitacaoServicoMedicao",
                column: "UsuarioID");

            migrationBuilder.AddForeignKey(
                name: "FK_SolicitacaoServicoItemMedicao_SolicitacaoServicoMedicao_SolicitacaoServicoMedicaoID",
                table: "SolicitacaoServicoItemMedicao",
                column: "SolicitacaoServicoMedicaoID",
                principalTable: "SolicitacaoServicoMedicao",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SolicitacaoServicoItemMedicao_SolicitacaoServicoMedicao_SolicitacaoServicoMedicaoID",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropTable(
                name: "SolicitacaoServicoMedicao");

            migrationBuilder.DropIndex(
                name: "IX_SolicitacaoServicoItemMedicao_SolicitacaoServicoMedicaoID",
                table: "SolicitacaoServicoItemMedicao");

            migrationBuilder.DropColumn(
                name: "SolicitacaoServicoMedicaoID",
                table: "SolicitacaoServicoItemMedicao");
        }
    }
}
