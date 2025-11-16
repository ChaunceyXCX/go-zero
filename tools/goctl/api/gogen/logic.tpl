// Code scaffolded by goctl. Safe to edit.
// goctl {{.version}}

package {{.pkgName}}

import (
	{{.imports}}
)

type {{.logic}} struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

{{if .hasDoc}}{{.doc}}{{end}}
func New{{.logic}}(ctx context.Context, svcCtx *svc.ServiceContext) *{{.logic}} {
	return &{{.logic}}{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *{{.logic}}) {{.function}}({{.request}}) {{.responseType}} {
	{{if eq .function "Add"}}
	var dbObj model.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}
	err := copier.Copy(&dbObj, req)
	if err != nil {
		return errx.BizErr("copy dbObj failed")
	}
	dbObj.ID = utils.GetIDInt64()
	if err := l.svcCtx.Query.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.WithContext(l.ctx).Create(&dbObj); err != nil {
		return errx.GORMErr(err)
	}
	return nil
	{{else if eq .function "Update"}}
	toMapOmit := utils.StructToMapOmit(req.{{(upperFirst .pkgName)}}Base, nil, nil, true)
	if _, err := l.svcCtx.Query.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.WithContext(l.ctx).Where(l.svcCtx.Query.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.ID.Eq(req.ID)).Updates(toMapOmit); err != nil {
		return errx.GORMErr(err)
	}
	return nil
	{{else if eq .function "Info"}}
	q := l.svcCtx.Query
	dbObj, err := q.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.WithContext(l.ctx).Where(q.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.ID.Eq(req.Id)).First()
	if err != nil {
		return nil, errx.GORMErr(err)
	}
	err = copier.Copy(&resp, dbObj)
	return
	{{else if eq .function "Delete"}}
	q := l.svcCtx.Query
	if _, err := q.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.WithContext(l.ctx).Where(q.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.ID.In(req.Ids...)).Unscoped().Delete(); err != nil {
		return errx.GORMErr(err)
	}
	return nil
	{{else if eq .function "PageSet"}}
	offset := (req.PageNum - 1) * req.PageSize
	q := l.svcCtx.Query
	do := q.{{.extend.modelPrefix}}Account.WithContext(l.ctx)
	// TODO 这里补充查询条件

	result, count, err := do.Order(q.{{.extend.modelPrefix}}{{(upperFirst .pkgName)}}.ID.Asc()).FindByPage(int(offset), int(req.PageSize))
	if err != nil {
		return nil, errx.GORMErr(err)
	}
	resp = new(types.PageSet{{(upperFirst .pkgName)}}Resp)
	resp.Total = count
	resp.Rows = make([]*types.{{(upperFirst .pkgName)}}Base, len(result))
	for i, item := range result {
		creator := new(types.{{(upperFirst .pkgName)}}Base)
		if err = copier.Copy(&creator, item); err != nil {
			return nil, err
		}
		resp.Rows[i] = creator
	}
	resp.Total = count
	return
	{{end}}

}
