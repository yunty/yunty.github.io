import { loadQuartzConfig, loadQuartzLayout } from "./quartz/plugins/loader/config-loader"
import { componentRegistry } from "./quartz/components/registry"

// 탐색기에서 폴더/파일 앞의 번호(01_, 03_ ...)는 정렬에만 쓰고 화면에는 숨긴다.
// 이 함수들은 브라우저로 직렬화되어 실행될 수 있어서 바깥 변수를 쓰지 않는다.
componentRegistry.setOptionOverrides("@quartz-community/explorer", {
  mapFn: (node: any) => {
    const names: Record<string, string> = {
      "01_java": "자바",
      "03_디자인 패턴": "디자인 패턴",
      "05_git": "깃",
    }
    const original: string = node.displayName
    node.displayName = names[original.toLowerCase()] ?? original.replace(/^\d+_/, "").replace(/_/g, " ")
  },
  sortFn: (a: any, b: any) => {
    if (a.isFolder !== b.isFolder) return a.isFolder ? -1 : 1
    // 최상위 카테고리는 정해 둔 순서대로, 새로 생긴 폴더는 그 뒤, 회고는 항상 맨 끝
    // (이 함수는 브라우저로 직렬화되므로 이름 붙인 보조 함수를 만들지 않는다)
    const order = ["01_java", "03_디자인-패턴", "05_git", "06_cs", "네트워크"]
    const ia = order.indexOf(a.slugSegment)
    const ib = order.indexOf(b.slugSegment)
    const ra = !a.isFolder ? -1 : a.slugSegment === "회고" ? 1000 : ia >= 0 ? ia : 500
    const rb = !b.isFolder ? -1 : b.slugSegment === "회고" ? 1000 : ib >= 0 ? ib : 500
    if (ra !== rb) return ra - rb
    return a.slugSegment.localeCompare(b.slugSegment, undefined, { numeric: true, sensitivity: "base" })
  },
})

const config = await loadQuartzConfig()
export default config
export const layout = await loadQuartzLayout()
