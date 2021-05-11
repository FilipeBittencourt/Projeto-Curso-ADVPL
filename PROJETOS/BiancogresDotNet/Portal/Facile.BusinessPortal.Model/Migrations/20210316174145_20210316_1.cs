using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210316_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SolicitacaoServicoMedicaoUnica",
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
                    Observacao = table.Column<string>(nullable: true),
                    NomeAnexo = table.Column<string>(nullable: true),
                    TipoAnexo = table.Column<string>(nullable: true),
                    ArquivoAnexo = table.Column<byte[]>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SolicitacaoServicoMedicaoUnica", x => x.ID);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicaoUnica_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicaoUnica_SolicitacaoServico_SolicitacaoServicoID",
                        column: x => x.SolicitacaoServicoID,
                        principalTable: "SolicitacaoServico",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicaoUnica_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SolicitacaoServicoMedicaoUnica_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicaoUnica_EmpresaID",
                table: "SolicitacaoServicoMedicaoUnica",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicaoUnica_SolicitacaoServicoID",
                table: "SolicitacaoServicoMedicaoUnica",
                column: "SolicitacaoServicoID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicaoUnica_UnidadeID",
                table: "SolicitacaoServicoMedicaoUnica",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_SolicitacaoServicoMedicaoUnica_UsuarioID",
                table: "SolicitacaoServicoMedicaoUnica",
                column: "UsuarioID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SolicitacaoServicoMedicaoUnica");
        }
    }
}
