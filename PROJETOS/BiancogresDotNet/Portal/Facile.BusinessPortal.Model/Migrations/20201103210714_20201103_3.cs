using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201103_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ObservacaoMedicao",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AtendimentoHistorico",
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
                    AtendimentoID = table.Column<long>(nullable: false),
                    UsuarioID = table.Column<long>(nullable: false),
                    DataEvento = table.Column<DateTime>(nullable: false),
                    Observacao = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AtendimentoHistorico", x => x.ID);
                    table.ForeignKey(
                        name: "FK_AtendimentoHistorico_Atendimento_AtendimentoID",
                        column: x => x.AtendimentoID,
                        principalTable: "Atendimento",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AtendimentoHistorico_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AtendimentoHistorico_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AtendimentoHistorico_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoHistorico_AtendimentoID",
                table: "AtendimentoHistorico",
                column: "AtendimentoID");

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoHistorico_EmpresaID",
                table: "AtendimentoHistorico",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoHistorico_UnidadeID",
                table: "AtendimentoHistorico",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoHistorico_UsuarioID",
                table: "AtendimentoHistorico",
                column: "UsuarioID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AtendimentoHistorico");

            migrationBuilder.DropColumn(
                name: "ObservacaoMedicao",
                table: "Atendimento");
        }
    }
}
